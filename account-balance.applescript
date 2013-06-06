on format_number(the_number, decimals, decimal_separator, thousand_separator)
	-- the_number is the number to be formatted.
	-- decimals is the number of decimal places. Must be 0 or greater.
	--    Anything beyond 16 does not make much sense with AppleScript numbers
	
	set decimals to decimals as integer -- make sure, decimals is an integer
	-- make sure, types are OK
	set the_number to the_number as number
	set decimal_separator to decimal_separator as text
	set thousand_separator to thousand_separator as text
	
	if decimals < 0 then
		error "Number for decimals out of range in handler Òformat_numberÓ" number 1700
	end if
	
	-- the code needs positive numbers.
	-- So, change negatives and deal with zeroes
	set the_sign to "" -- change the empty string to "+" if you want signed numbers
	if the_number < 0 then
		set the_sign to "-"
		set the_number to -the_number
	end if
	
	-- shift the decimal point and round to an integer
	set x to (the_number * (10 ^ decimals) + 0.5) div 1
	
	-- getting digits of the integer without exponential notation
	-- retrieve digits from the right, one by one
	set X_digits to ""
	repeat while x is not less than 1
		set X_digits to (((x mod 10) as integer) as string) & X_digits
		set x to x div 10
	end repeat
	
	-- pad with 0 if two short (happens, when the_number between -1 and 1)
	repeat while (length of X_digits < decimals + 1)
		set X_digits to "0" & X_digits
	end repeat
	
	-- extract digits after decimal point
	set D_digits to ""
	if decimals > 0 then
		set D_digits to text -decimals thru -1 of X_digits
	end if
	
	-- extract digits before decimal point
	set X_digits to text 1 thru (-decimals - 1) of X_digits
	
	-- remove this section, if thousad separators are not needed
	-- create string with thousand_separator inserted
	if thousand_separator is not equal to "" then
		set X2_digits to ""
		set temp to X_digits
		repeat while (length of temp) > 3
			set X2_digits to (text -3 thru -1 of temp) & X2_digits
			set X2_digits to thousand_separator & X2_digits
			set temp to text 1 thru -4 of temp
		end repeat
		set X2_digits to temp & X2_digits
		set X_digits to X2_digits
	end if
	-- end remove
	
	if decimals = 0 then
		return the_sign & X_digits
	end if
	return the_sign & X_digits & decimal_separator & D_digits
end format_number

on roundThis(n, numDecimals)
	set x to 10 ^ numDecimals
	(((n * x) + 0.5) div 1) / x
end roundThis

on run {input, parameters}
	set balance to do shell script "pjson () { python -c \"import json; import sys; json = json.loads(sys.stdin.read()); print json['result']['account_data']['Balance']\"; };curl -H \"Accept: application/json\" -H \"Content-type: application/json\" -X POST -d '{\"method\":\"account_info\",\"params\":[{\"account\":\"" & input & "\"}]}' http://s1.ripple.com:51234 | pjson"
	
	display alert "This guy has " & format_number((roundThis((balance / 1000000), 2) as integer), 0, ".", ",") & " XRP"
end run