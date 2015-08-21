function [rs, nrow, ncol] = im2col_overlap(data, size1, overlapPixel, maps)
op = overlapPixel;
[row, col]=size(data);
s1 = size1;
ct = 1;
ps = prod(s1);
if (op==0)
    rs = single(zeros(ps, row*col/ps));
else
    rs = single(zeros(ps, round(row*col/(ps-op^2))));
end
i =0; j = 0;
if (~exist('maps', 'var')), maps=[]; end
for i=1:s1(1)-op:row-s1(1)+1
    for j=1:s1(2)-op:col-s1(2)+1
        rrow = i:i+s1(1)-1;
        rcol = j:j+s1(2)-1;
        if ~isempty(maps)
            varify = mean2(maps(rrow, rcol));
        end
        if (~isempty(maps) && varify>0.2) || isempty(maps)
            v = data(rrow,rcol);
            rs(:, ct) = reshape(v, ps, 1);
            ct = ct+1;
        end
    end
end
rs(:, ct:end)=[];
nrow = i+s1(1)-1;
ncol = j+s1(2)-1;