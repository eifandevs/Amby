
var searchResultCount = 0;
const highLightClassName = "AmbyHighlight";

function scrollIntoViewWithIndex(index) {
    document.getElementsByClassName(highLightClassName)[index].scrollIntoView(true);
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
                span.setAttribute("class",highLightClassName);
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
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    highlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}

function highlightAllOccurencesOfString(keyword) {
    removeAllHighlights();
    highlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
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
