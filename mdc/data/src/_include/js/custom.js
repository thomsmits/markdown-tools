  function deprettyfy(input) {
    var cleaned = input.replace(/<[^>]*>/g, '')
                       .replace(/&lt;/g, '<')
                       .replace(/&gt;/g, '>')
                       .replace(/&nbsp;/g, ' ');
                   
    return cleaned;
  }

  function transfer(src, dest) {
    var source = document.getElementById(src).innerHTML;
    var destination = document.getElementById(dest);    
    destination.innerHTML = deprettyfy(source);
  }
    
  function logLine(text) {
    var date = new Date();  
    var ts = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
    return ts + " - " + text;
  }
  
  /*
  function log(id, text) {
    var element = document.getElementById(id + "_output");    
    var paragraph = document.createElement("p");
    var entry = document.createTextNode(logLine(text));
    paragraph.appendChild(entry);
    paragraph.className = "log";
    element.appendChild(paragraph);
  }
  */
  
  function show(id, text) {
    var element = document.getElementById(id + "_output");
    var entry = document.createTextNode(text);
    
    while (element.firstChild) {
      element.removeChild(element.firstChild);
    }

    element.appendChild(entry);
  }


  
  function findChild(element, name) {
    
    if (element.getAttribute && element.getAttribute("name") === name) {
      return element;
    }
    else {    
      var children = element.childNodes;
    
      for (var i = 0; i < children.length; i++) {
        var e = children[i]; 
        var result = findChild(e, name);
      
        if (result) {
          return result;
        }
      }      
    }
    return undefined;
  }
  
  
  
  function getElementByName(element, name) {
    var parent = element.parentNode;
    
    while (parent.className !== "present") {
      parent = parent.parentNode;
    }
      
    return findChild(parent, name);
  }
  
  
  function toDataURL(source, insert) {
    var result = "data:text/html;charset=utf-8,";
    
    result += source.replace(/!!STYLE!!/g, insert)
                    .replace(/\n/g, '%0A')
                    .replace(/</g, '%3C')
                    .replace(/>/g, '%3E')
                    .replace(/ /g, '%20');
                          
    return result;
  }
  
  function sync(element) {
  
    var html = deprettyfy(getElementByName(element, "src").innerHTML);
    var dest = getElementByName(element, "dest");
    
    if (dest) {
      dest.innerHTML = html; 
    }
  }
  
  function syncIframe(element, html) {
    var style = deprettyfy(getElementByName(element, "src").innerHTML);
    var dest = getElementByName(element, "dest");
    
    dest.src = toDataURL(html, style);
  }
  
  
  var logArea;

  function attachHandler(element) {
      var parents = $(element).parents("section");
      var input = parents.find("pre code");
      var output = parents.find("[name='html_output']");

      input.bind("keyup", function() {
          var content = deprettyfy(input.html());
          output.html(content);
          return true;
      });

      var content = deprettyfy(input.html());
      output.html(content);
  }

  function attachHandlerCSS(element, template) {
      var parents = $(element).parents("section");
      var input = parents.find("pre code");
      var output = parents.find("iframe");

      input.bind("keyup", function() {
          var content = deprettyfy(input.html());
          output.attr("src", toDataURL(template, deprettyfy(content)));
          return true;
      });

      var content = deprettyfy(input.html());
      output.attr("src", toDataURL(template, deprettyfy(content)));
  }

  function attachPreviousHandler(element) {
      var parents = $(element).parents('section');
      var input =  parents.prev().find('pre code');
      var output = parents.find("[name='html_output']");

      input.bind("keyup", function() {
          var content = deprettyfy(input.html());
          output.html(content);
          return true;
      });

      var content = deprettyfy(input.html());
      output.html(content);
  }

  function synchronize(element) {
      var parents = $(element).parent("section");
      var input = parents.find("pre code");
      var output = element;
      var content = deprettyfy(input.html());
      output.html(content);
  }

  function synchronizePrevious(element) {
      var previous = $(element).parent().prev("section");
      var input = previous.find("pre code");
      var output = element;
      var content = deprettyfy(input.html());
      output.html(content);
  }

  function synchronizeCSS(element, template) {
      var parents = $(element).parent("section");
      var input = parents.find("pre code");
      var output = parents.find("iframe");
      var content = deprettyfy(input.html());
      output.attr("src", toDataURL(template, deprettyfy(content)));
  }

  function executePre(element) {
      var pre = $(element).parent("section").find("[name='pre']").html();
      executeNew(element, pre);
  }

  function executeNew(element, pre) {

      var parents = $(element).parents("section.slide");
      var codeElement = parents.find("pre code");
      var logElement = parents.find("[name='log']");
      var script = deprettyfy(codeElement.html());

      logArea = logElement.get(0);
      logArea.innerHTML = "";

      if (pre) {
        script = pre + script;
      }

      eval(script);
  }

  function execute(element, pre) {
  
    var parent = element.parentNode;

    if (parent.nodeName.toLocaleLowerCase() === "p") {
        parent = parent.parentNode;
    }

    var codeElements = parent.getElementsByTagName("code");
    var script = "";
    
    for (var i = 0; i < codeElements.length; i++) {
      var code = codeElements[i];
      if (code.getAttribute("name") === "src") {
        script = deprettyfy(code.innerHTML);
        break;
      }
    }
      
    var divs = parent.getElementsByTagName("div");
    
    if (divs.length === 0) {
      divs = parent.getElementsByTagName("span");
    }
    
    for (var k = 0; k < divs.length; k++) {
      var div = divs[k];
      if (div.getAttribute("name") === "log") {
        logArea = div;
        break;
      }
    }
    
    logArea.innerHTML = "";
    
    if (pre) {
      script = pre + script;
    }
      
    eval(script);      
  }
  
  function update(element) {
    var html = deprettyfy(element.parentNode.getElementsByTagName("code")[0].innerHTML);    
    var divs = element.parentNode.parentNode.getElementsByTagName("div");
    
    for (var i = 0; i < divs.length; i++) {
      var e = divs[i];
      if (e.getAttribute("name") === "result") {
        e.innerHTML = html; 
        break;
      }
    }
  }
  
  function log(text) {   
    var paragraph = document.createElement("p");
    paragraph.class = "log";
    var entry = document.createTextNode(text);
    paragraph.appendChild(entry);
    paragraph.className = "log";
    logArea.appendChild(paragraph);
  }
 
  function updateCss(id) {
    var css = document.getElementById(id).innerHTML;
    var element = document.getElementById(id + "_target");
    element.setAttribute("style", css);  
  }
  
  function updateHtml(id) {
    var html = document.getElementById(id).innerHTML;
    var element = document.getElementById(id + "_target");
    element.innerHTML = deprettyfy(html); 
  }  