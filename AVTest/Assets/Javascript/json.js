function output(rawJSON) {
	var codeBlock = document.createElement('pre');
	codeBlock.innerHTML = rawJSON;
	
	document.body.innerHTML = '';
    document.body.appendChild(codeBlock);
}

function syntaxHighlight(json) {
    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function(match) {
        var cls = 'number';
        if (/^"/.test(match)) {
            if (/:$/.test(match)) {
                cls = 'key';
            } else {
                cls = 'string';
            }
        } else if (/true|false/.test(match)) {
            cls = 'boolean';
        } else if (/null/.test(match)) {
            cls = 'null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
    });
}

function loadStyle(styleString) {
	var style = document.createElement('style'); 
	style.innerHTML = styleString; 
	document.head.appendChild(style);
}

function convertAndDisplay(rawString) {
    var str = JSON.stringify(rawString, undefined, 4);
    output(syntaxHighlight(str));
}