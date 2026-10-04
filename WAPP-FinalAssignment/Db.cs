using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace WAPP_FinalAssignment
{
    /// <summary>
    /// Lightweight ADO.NET data-access helper. Handles connection lifetime,
    /// parameterised queries, and DBNull conversion for the LMS database.
    /// All methods are safe to call from page event handlers and will throw
    /// on connection errors so callers can decide how to surface them.
    /// </summary>
    internal static class Db
    {
        // ── Connection ────────────────────────────────────────────────────
        public static string ConnectionString
        {
            get
            {
                var cs = ConfigurationManager.ConnectionStrings["DatabasesConnectionString"];
                if (cs == null || string.IsNullOrWhiteSpace(cs.ConnectionString))
                    throw new InvalidOperationException(
                        "Connection string 'DatabasesConnectionString' is not configured in Web.config.");
                return cs.ConnectionString;
            }
        }

        public static SqlConnection OpenConnection()
        {
            var conn = new SqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }

        // ── Parameter helpers ─────────────────────────────────────────────
        /// <summary>
        /// Build a SqlParameter, converting null/empty into DBNull and trimming string inputs.
        /// </summary>
        public static SqlParameter P(string name, object value)
        {
            object dbValue = value;
            if (value == null) dbValue = DBNull.Value;
            else if (value is string s)
            {
                var trimmed = s.Trim();
                dbValue = trimmed.Length == 0 ? (object)DBNull.Value : trimmed;
            }
            return new SqlParameter(name, dbValue);
        }

        /// <summary>
        /// Typed parameter when explicit DbType is needed.
        /// </summary>
        public static SqlParameter P(string name, SqlDbType type, object value)
        {
            var p = new SqlParameter(name, type) { Value = value ?? DBNull.Value };
            return p;
        }

        // ── ExecuteNonQuery ───────────────────────────────────────────────
        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (var conn = OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }

        // ── ExecuteScalar (typed + null safe) ─────────────────────────────
        public static T ExecuteScalar<T>(string sql, params SqlParameter[] parameters)
        {
            using (var conn = OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                var raw = cmd.ExecuteScalar();
                if (raw == null || raw == DBNull.Value) return default(T);
                try { return (T)Convert.ChangeType(raw, typeof(T), CultureInfo.InvariantCulture); }
                catch { return default(T); }
            }
        }

        // ── ExecuteIdentity (INSERT then return new identity) ─────────────
        public static int ExecuteInsertReturnId(string insertSql, params SqlParameter[] parameters)
        {
            // Append SCOPE_IDENTITY only if not already present
            string finalSql = insertSql.TrimEnd().EndsWith(";", StringComparison.Ordinal)
                ? insertSql + " SELECT CAST(SCOPE_IDENTITY() AS INT);"
                : insertSql + "; SELECT CAST(SCOPE_IDENTITY() AS INT);";

            using (var conn = OpenConnection())
            using (var cmd = new SqlCommand(finalSql, conn))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                var raw = cmd.ExecuteScalar();
                if (raw == null || raw == DBNull.Value) return 0;
                int parsed;
                if (int.TryParse(raw.ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out parsed))
                    return parsed;
                return 0;
            }
        }

        // ── ExecuteReader → DataTable ─────────────────────────────────────
        public static DataTable Query(string sql, params SqlParameter[] parameters)
        {
            var dt = new DataTable();
            using (var conn = OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var adapter = new SqlDataAdapter(cmd))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                adapter.Fill(dt);
            }
            return dt;
        }

        // ── ExecuteReader → list of dictionaries ──────────────────────────
        public static List<Dictionary<string, object>> QueryDict(string sql, params SqlParameter[] parameters)
        {
            var rows = new List<Dictionary<string, object>>();
            using (var conn = OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var row = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            object v = reader.IsDBNull(i) ? null : reader.GetValue(i);
                            row[reader.GetName(i)] = v;
                        }
                        rows.Add(row);
                    }
                }
            }
            return rows;
        }

        // ── Single-row helper ─────────────────────────────────────────────
        public static DataRow QueryOne(string sql, params SqlParameter[] parameters)
        {
            var dt = Query(sql, parameters);
            return (dt != null && dt.Rows.Count > 0) ? dt.Rows[0] : null;
        }

        // ── Transaction support (cascade deletes) ─────────────────────────
        public static void RunInTransaction(Action<SqlConnection, SqlTransaction> action)
        {
            if (action == null) throw new ArgumentNullException(nameof(action));
            using (var conn = OpenConnection())
            using (var tx = conn.BeginTransaction())
            {
                try
                {
                    action(conn, tx);
                    tx.Commit();
                }
                catch
                {
                    try { tx.Rollback(); } catch { /* swallow rollback errors */ }
                    throw;
                }
            }
        }

        public static int ExecuteNonQueryTx(SqlConnection conn, SqlTransaction tx, string sql, params SqlParameter[] parameters)
        {
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                if (parameters != null && parameters.Length > 0)
                    cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }

        // ── Type conversion helpers (NaN/null safe) ───────────────────────
        public static int ToInt(object value, int fallback = 0)
        {
            if (value == null || value == DBNull.Value) return fallback;
            int result;
            return int.TryParse(value.ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out result)
                ? result : fallback;
        }

        public static double ToDouble(object value, double fallback = 0d)
        {
            if (value == null || value == DBNull.Value) return fallback;
            double result;
            if (double.TryParse(value.ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out result)
                && !double.IsNaN(result) && !double.IsInfinity(result))
                return result;
            return fallback;
        }

        public static string ToStr(object value, string fallback = "")
        {
            if (value == null || value == DBNull.Value) return fallback;
            return value.ToString();
        }

        public static DateTime ToDate(object value, DateTime? fallback = null)
        {
            if (value == null || value == DBNull.Value)
                return fallback ?? DateTime.Today;
            DateTime result;
            if (value is DateTime dt) return dt;
            return DateTime.TryParse(value.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out result)
                ? result : (fallback ?? DateTime.Today);
        }

        public static bool ToBool(object value, bool fallback = false)
        {
            if (value == null || value == DBNull.Value) return fallback;
            bool result;
            if (bool.TryParse(value.ToString(), out result)) return result;
            // SQL bit can come back as 0/1
            int n;
            if (int.TryParse(value.ToString(), out n)) return n != 0;
            return fallback;
        }

        // ── Password hashing (SHA-256 hex, fits VARCHAR(64)) ──────────────
        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentException("Password cannot be empty.", nameof(password));
            using (var sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                var sb = new StringBuilder(bytes.Length * 2);
                foreach (var b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // ── HTML safe display ─────────────────────────────────────────────
        public static string SafeHtml(string raw)
        {
            return raw == null ? string.Empty : HttpUtility.HtmlEncode(raw);
        }
    }
}
