import QtQuick 2.0
import QtWebView 1.1

WebView
{
	id: webView
	clip: true
	onLoadingChanged:
	{
		if (loadRequest.errorString)
			console.error(loadRequest.errorString);
	}
}
