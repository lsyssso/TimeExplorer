function setStamp(imgDir)
/*
change the directory of source of HTML element, and save it to localStorage
*/
{
    $("#selectedStamp").find("img").attr("src", "img/" + imgDir);
    localStorage.setItem("stamp", imgDir);
}

function getStamp()
/*
load an image from localStorage and put it to the src attribute
*/
{
    var stamp = localStorage.getItem("stamp");
    if(stamp)
    {
        $("#selectedStamp").find("img").attr("src", "img/" + stamp);
    }
    
    
}


function selectType(type)
/*
redirecting page based on the selection of user
*/
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
/*
save cover selection to localStorage
*/
{
    localStorage.setItem("cover", cover);
    window.location.href = "stamp.html";
}

function finishCoverSelection()
/*
use default cover
*/
{
    selectCover("cbc001", ".pic");
}

function finishLetter()
/*
use default envelope colour
*/
{
    localStorage.setItem("cover", "Ivory");
    if(setContent())
    {
         window.location.href = "time.html";
    }
}

function setContent()
/*
check if user input anything to text area, if so, store the text to
localStorage, otherwise pop a message.
*/
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
/*
check if user input anything to text area, if so, store the stamp to
localStorage, and proceed, otherwise pop a message.
*/
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
/*
For this prototype which will be presented on 6th of June
store the date and selected time to localStorage
*/
{
    var time = "2018-06-08 " + $("#timePicker").val();
    localStorage.setItem("toDate", time);
    //alert(localStorage.getItem("toDate"));

}

function send()
/*
pack all user selection and post it to data server
*/
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
            alert("Failed to connect data server");
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