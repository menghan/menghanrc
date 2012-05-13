function FindProxyForURL(url, host)
{
	var proxy_douban = "PROXY 10.8.0.1:8118";
	var proxy_null   = "DIRECT";
	// var proxy_douban = "DIRECT";

	var re_twitter = /twitter\.com|t\.co/;
	var re_google = /\.google\.com|\.google\.com\.hk|\.google\.com\.jp|ssl\.gstatic\.com/|googleusercontent\.com;
	var re_youtube = /youtube\.com|\.ytimg\.com/;
	var re_caoliu = /cl\./;
	var re_wordpress = /\.wordpress\.com/;
	var re_trello = /trello\.com|amazonaws\.com|cloudfront\.net/;

	if (re_twitter.test(host)) {
		return proxy_douban;
	}
	if (re_google.test(host)) {
		return proxy_douban;
	}
	if (re_youtube.test(host)) {
		return proxy_douban;
	}
	if (re_caoliu.test(host)) {
		return proxy_douban;
	}
	if (re_wordpress.test(host)) {
		return proxy_douban;
	}
	if (re_trello.test(host)) {
		return proxy_douban;
	}

	return proxy_null;

	// if (isInNet(myIpAddress(), "192.168.1.0", "255.255.255.0"))
	//         return "PROXY 192.168.1.1:8080";
	// else
	//         return "DIRECT";
}
