on roundThis(n, numDecimals)
	set x to 10 ^ numDecimals
	(((n * x) + 0.5) div 1) / x
end roundThis

on run {input, parameters}
	set balance to do shell script "pjson () { python -c \"import json; import sys; json = json.loads(sys.stdin.read()); print json['result']['account_data']['Balance']\"; };curl -H \"Accept: application/json\" -H \"Content-type: application/json\" -X POST -d '{\"method\":\"account_info\",\"params\":[{\"account\":\"" & input & "\"}]}' http://s1.ripple.com:51234 | pjson"
	
	display alert "This guy has " & (roundThis((balance / 1000000), 2) as integer) & " XRP"
end run