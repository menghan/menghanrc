if has("win32")
	"about encoding
	set encoding=cp936
	set termencoding=cp936
	set langmenu=zh_CN.utf-8
	set fileencoding=cp936
	set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,sjis,euc-kr,ucs-2le,latin1 
	syntax on "for safe
else
	"about encoding
	""" some knowledge
	" Use cp936 to support GBK, euc-cn == gb2312
	" cp950, big5 or euc-tw
	" Are they equal to each other?
	""" normal setting
	""	set encoding=utf-8
	""	set termencoding=utf-8
	""	set fileencoding=utf-8
	""	set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,sjis,euc-kr,ucs-2le,latin1
	set encoding=utf-8
	""" CJK and other environments detection and corresponding setting
	if v:lang =~ "^zh_CN"
		set encoding=cp936
		set termencoding=cp936
		set fileencoding=cp936
		set fileencodings=ucs-bom,utf-8,cp936,cp950,gb18030,big5,euc-jp,sjis,euc-kr,ucs-2le,latin1
	elseif v:lang =~ "^zh_TW"
		"set encoding=big5
		set termencoding=big5
		set fileencodings=ucs-bom,big5,utf-8,cp936,gb18030,euc-jp,sjis,euc-kr,ucs-2le,latin1
		set fileencoding=big5
	elseif v:lang =~ "^ko"
		"set encoding=euc-kr
		set termencoding=euc-kr
		set fileencodings=ucs-bom,euc-kr,utf-8,cp936,gb18030,big5,euc-jp,sjis,ucs-2le,latin1
		set fileencoding=euc-kr
	elseif v:lang =~ "^ja_JP"
		"set encoding=euc-jp
		set termencoding=euc-jp
		set fileencodings=ucs-bom,euc-jp,utf-8,cp936,gb18030,big5,sjis,euc-kr,ucs-2le,latin1
		set fileencoding=euc-jp
	endif
	""" UTF-8 environments detection and corresponding setting
	if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
		set encoding=utf-8
		set termencoding=utf-8
		set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,sjis,euc-kr,latin1
		" set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,sjis,euc-kr,ucs-2le,latin1
		set fileencoding=utf-8
	endif
endif
