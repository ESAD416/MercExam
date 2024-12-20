using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TestWebApplication.Service;

namespace TestWebApplication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MyOfficeController : Controller
    {
        private readonly MyOfficeService _myOfficeService;
        public MyOfficeController(MyOfficeService myOfficeService)
        {
            _myOfficeService = myOfficeService;
        }

        // GET: MyOfficeController
        public ActionResult Index()
        {
            return View();
        }

        // POST: api/MyOffice/Select
        [HttpPost("Select")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ACPDDetails([FromBody] string jsonData)
        {
            try
            {
                // 呼叫 MyOfficeService 執行存儲過程
                var resultJson = await _myOfficeService.GetACPDDataAsync(jsonData);
                // 返回 JSON 結果
                return Ok(resultJson);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }

        // POST: api/MyOffice/Insert
        [HttpPost("Insert")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> InsertACPD([FromBody] string jsonData)
        {
            try
            {
                await _myOfficeService.InsertACPDDataAsync(jsonData);
                return Ok("Insert operation completed.");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }

        // POST: api/MyOffice/Insert
        [HttpPost("Update")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateACPD([FromBody] string jsonData)
        {
            try
            {
                await _myOfficeService.UpdateACPDDataAsync(jsonData);
                return Ok("Insert operation completed.");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }

        // POST: api/MyOffice/Update
        [HttpPost("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteACPD([FromBody] string jsonData)
        {
            try
            {
                await _myOfficeService.DeleteACPDDataAsync(jsonData);
                return Ok("Insert operation completed.");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }
    }
}
