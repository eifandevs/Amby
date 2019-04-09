var searchResultCount = 0;
var IGNORE_NODE_NAMES = {
EMBED: 1,
OBJECT: 1,
SCRIPT: 1,
STYLE: 1,
};

function scrollIntoViewWithIndex(index) {
    document.getElementsByClassName("AmbyHighlight")[index].scrollIntoView(true);
}

function isVisible(element) {
    var style = element.ownerDocument.defaultView.getComputedStyle(element, null);
    if (element.style.display == "none" || element.style.visibility == "hidden" || style.display == "none" || style.visibility == "hidden") {
        return false;
    }
    var rect = element.getBoundingClientRect();
    if (rect.width == 0 || rect.height == 0 || rect.left < 0) {
        return false;
    } else {
        return true;
    }
}

function frameDocuments() {
    var docs = [];
    var wins = [window];
    while (wins.length > 0) {
        var win = wins.pop();
        for (var i = 0; i < win.frames.length; i++) {
            try {
                win.frames[i].document && docs.push(win.frames[i].document); wins.push(win.frames[i]);
            } catch (e) { }
        }
    }
    return docs;
}

function highlightAllOccurencesOfStringForElement(element,keyword) {
    if (element) {
        if (element.nodeType == 3) {
            while (true) {
                var value = element.nodeValue;
                var idx = value.toLowerCase().indexOf(keyword);
                
                if (idx < 0) break;
                
                var span = document.createElement("span");
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                span.setAttribute("class","AmbyHighlight");
                span.style.backgroundColor="yellow";
                span.style.color="black";
                text = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
                searchResultCount++;
            }
        } else if (element.nodeType == 1) {
            if (isVisible(element) && element.nodeName.toLowerCase() != 'select' && !IGNORE_NODE_NAMES[element.tagName]) {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    highlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}

function highlightAllOccurencesOfString(keyword) {
    removeAllHighlights();
    var docs = [document].concat(frameDocuments());
    for (var i = 0; i < docs.length; i++) {
        var doc = docs[i];
        highlightAllOccurencesOfStringForElement(doc.body, keyword.toLowerCase());
    }
    return searchResultCount;
}

function removeAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == "AmbyHighlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (removeAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}

function removeAllHighlights() {
    searchResultCount = 0;
    removeAllHighlightsForElement(document.body);
}
