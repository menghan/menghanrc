function FindProxyForURL(url, host)
{
	var proxy_douban = "PROXY 10.8.0.1:8118";
	var proxy_null   = "DIRECT";

	var re_twitter = /twitter\.com|t\.co|twimg\.com/;
	var re_google = /google\.com|google\.com\.hk|google\.com\.jp|ssl\.gstatic\.com|googleusercontent\.com|googleapis\.com|goo\.gl|blogspot\.|blogblog\.com|blogger\.com/;
	var re_youtube = /youtube\.com|ytimg\.com/;
	var re_caoliu = /cl\./;
	var re_wordpress = /wordpress\.com/;
	var re_trello = /trello\.com|amazonaws\.com|cloudfront\.net/;
	var re_evernote = /evernote\.com/;
	var re_ichangtou = /ichangtou\.com/;
	var re_facebook = /facebook\.com/;
	var re_dropbox = /dropbox\.com|dropboxdocs\.com/;
	var re_amazon = /amazon\.com|akamaihd\.net|akamai\.net/;
	var re_slideshare = /slideshare\.net/;
	var re_feedburner = /feeds\.feedburner\.com/;
	var re_mail_archive = /mail-archive\.com/;
	var re_golang = /golang\.org/;
	var re_python = /python\.org/;
	var re_nytimes = /nytimes\.com/;
	var re_list_debian = /list\.debian\.org/;
	var re_sourceforge = /sourceforge\.net/;

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
	if (re_evernote.test(host)) {
		return proxy_douban;
	}
	if (re_ichangtou.test(host)) {
		return proxy_douban;
	}
	if (re_facebook.test(host)) {
		return proxy_douban;
	}
	if (re_dropbox.test(host)) {
		return proxy_douban;
	}
	if (re_amazon.test(host)) {
		return proxy_douban;
	}
	if (re_slideshare.test(host)) {
		return proxy_douban;
	}
	if (re_feedburner.test(host)) {
		return proxy_douban;
	}
	if (re_mail_archive.test(host)) {
		return proxy_douban;
	}
	if (re_golang.test(host)) {
		return proxy_douban;
	}
	if (re_python.test(host)) {
		return proxy_douban;
	}
	if (re_nytimes.test(host)) {
		return proxy_douban;
	}
	if (re_list_debian.test(host)) {
		return proxy_douban;
	}
	if (re_sourceforge.test(host)) {
		return proxy_douban;
	}

	return proxy_null;

	// if (isInNet(myIpAddress(), "192.168.1.0", "255.255.255.0"))
	//         return "PROXY 192.168.1.1:8080";
	// else
	//         return "DIRECT";
}
