using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Principal;

namespace WebApplication9.Controllers
{
    [Route("api/Authentification")]
    public class Authentification : Controller
    {
        [HttpGet]
        public JsonResult Index()
        {
            var user = Request.HttpContext.User.Identity.Name;
            if (string.IsNullOrEmpty(user))
            {
                user = WindowsIdentity.GetCurrent().Name;
            }
            return Json(user.Substring(user.IndexOf(@"\") + 1));
        }
    }
}