% dump data as single precision numbers into Intel HEX format

function [] = hexdump(data, filename)
    data = single(data);
    
    line = [];
    twos = [];
    result = [];
    
    for i = 1:length(data)
        %        size       address       type           data
        line = [':04', dec2hex(i - 1, 4), '00', upper(num2hex(data(i)))];
        % calculate checksum
        ch = 0;
        for oo = 1:(length(line) - 1) / 2
            ch = ch + hex2dec(line((2 * oo):(2 * oo + 1)));
        end
        sh = dec2bin(ch, 8);
        k = 1;
        for j = length(sh) - 7:length(sh)
            if sh(j) == '1'
                twos(k) = '0';
            else
                twos(k) = '1';
            end
            k = k + 1;
        end
        s = dec2hex((bin2dec(char(twos)) + 1), 2);
        result = [result, line, s(end - 1:end), char(13), char(10)];
    end
    result = [result, ':00000001FF', char(13), char(10)];
    f = fopen(filename, 'w');
    fprintf(f, '%c', result);
    fclose(f);
end