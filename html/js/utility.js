function setStamp(imgDir)
{
    $("#selectedStamp").find("img").attr("src", "img/" + imgDir);
    localStorage.setItem("stamp", imgDir);
}

function getStamp()
{
    var stamp = localStorage.getItem("stamp");
    if(stamp)
    {
        $("#selectedStamp").find("img").attr("src", "img/" + stamp);
    }
    
    
}


function selectType(type)
{
    localStorage.setItem("type", type);
    if(type == 0)
    {
        window.location.href = "photoletter.html";
    }
    else if(type == 2)
    {
        window.location.href = "selectcover.html";
    }
}

function selectCover(cover, tag)
{
    localStorage.setItem("cover", cover);
    window.location.href = "stamp.html";
    //$(tag).find("img").css("border-color", "#806954");
    //if(tag == ".pic")
    //{ 
    //    $(".pic1").find("img").css("border-color", "transparent");
    //    $(".pic2").find("img").css("border-color", "transparent");
    //}
    //else if(tag == ".pic1")
    //{
    //    $(".pic").find("img").css("border-color", "transparent");
    //    $(".pic2").find("img").css("border-color", "transparent");
    //}
    //else if(tag == ".pic2")
    //{
    //    $(".pic").find("img").css("border-color", "transparent");
    //    $(".pic1").find("img").css("border-color", "transparent");
    //}
    //alert(localStorage.getItem("cover"));
}

function finishCoverSelection()
{
    //var cover = localStorage.getItem("cover");
    window.location.href = "stamp.html";
}

function finishLetter()
{
    localStorage.setItem("cover", "Ivory");
    if(setContent())
    {
         window.location.href = "time.html";
    }
}

function setContent()
{
    var text = $(".letter").find("textarea").val();
    if(text == "")
    {
        alert("please write a message!");
        return false;
    }
    else
    {
        localStorage.setItem("message", text);
        //alert(localStorage.getItem("message"));
        return true;
    }
    
}


function setPostcardContent()
{
    if(localStorage.getItem("stamp") == null)
    {
        alert("please select a stamp!");
    }
    else
    {
        if(setContent())
        {
            window.location.href = "time.html";
        }
    }
}

function setTime()
{
    var time = "2018-05-25 " + $("#timePicker").val();
    localStorage.setItem("toDate", time);
    //alert(localStorage.getItem("toDate"));

}

function send()
{
    setTime();
    var date = new Date();
    
    var from = date.getFullYear() + '-'
                + '0' + (date.getMonth() + 1) + '-'
                + date.getDate() + ' '
                + date.getHours() + ':'
                + date.getMinutes();
    var message = 
    {
        type: localStorage.getItem("type"),
        toDate: localStorage.getItem("toDate"),
        cover: localStorage.getItem("cover"),
        stamp: localStorage.getItem("stamp"),
        message: localStorage.getItem("message"),
        selfie: localStorage.getItem("selfie"),
        fromDate: from
    };

    var json = JSON.stringify(message);
    //alert(json);
    //var url = "http://209.97.175.95:8080/add";
    $.ajax({
        type: "POST",
        url: "http://209.97.175.95:8082",
        dataType: "text",
        data: json,
        success: function(response) {
            if(response = "success")
	          {
            	window.location.href = "end.html";  
		}
		else
		{
			alert(response);
		}
        },
        error: function (request, status, error) {
            console.log(request.status);
            console.log(error);
        }
    }
    );
    
}



function back()
{
    window.history.back();
}