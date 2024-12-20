using System.Data;
using Dapper;
using TestWebApplication.Model;

namespace TestWebApplication.Service
{
    public class MyOfficeService
    {
        private readonly IDbConnection _dbConnection;

        // 通過 DI 注入 IDbConnection
        public MyOfficeService(IDbConnection dbConnection)
        {
            _dbConnection = dbConnection;
        }

        // 執行 MyOffice_ACPD_CRUD 操作
        public async Task<string> ExecuteCrudOperationAsync(string action, string jsonData)
        {
            // 用於存儲過程的 SQL 查詢結果
            string result = string.Empty;

            // 準備參數
            var parameters = new
            {
                Action = action,        // 操作類型：INSERT/UPDATE/DELETE/SELECT
                JsonData = jsonData     // JSON 格式的資料
            };

            if (action == "SELECT")
            {
                // 操作並返回結果（假設返回的是 JSON 格式的資料）
                var resultJson = await _dbConnection.QueryFirstOrDefaultAsync<string>(
                    "EXEC [dbo].[usp_Myoffice_ACPD_CRUD] @Action = 'SELECT', @JsonData = @JsonData",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                result = resultJson;
            }
            else
            {
                // 呼叫儲存過程並執行
                await _dbConnection.ExecuteAsync(
                    "usp_Myoffice_ACPD_CRUD",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                result = action + " complete!!";
            }

            return result;  // 返回結果，對於非 SELECT 會返回空字串
        }

        // 查詢資料 (如果操作是 SELECT)
        public async Task<string> GetACPDDataAsync(string jsonData)
        {
            return await ExecuteCrudOperationAsync("SELECT", jsonData);
        }
        // 插入資料 (如果操作是 INSERT)
        public async Task InsertACPDDataAsync(string jsonData)
        {
            await ExecuteCrudOperationAsync("INSERT", jsonData);
        }

        // 更新資料 (如果操作是 UPDATE)
        public async Task UpdateACPDDataAsync(string jsonData)
        {
            await ExecuteCrudOperationAsync("UPDATE", jsonData);
        }

        // 刪除資料 (如果操作是 DELETE)
        public async Task DeleteACPDDataAsync(string jsonData)
        {
            await ExecuteCrudOperationAsync("DELETE", jsonData);
        }
    }
}
