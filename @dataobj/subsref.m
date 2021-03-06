function b = subsref(a,index)
%SUBSREF Define field name indexing for dataobj objects

expr='';
for j=1:length(index),
  switch index(j).type
    case '()'
      if j==1,
        switch index(j).subs{:}
          case 1,
            expr='.GlobalAttributes';
          case 2,
            expr='.VariableAttributes';
          otherwise
            error('Index out of range')
        end
      else
        expr=[expr index(j).subs];
      end
    case '.'
      expr=[expr '.' index(j).subs];
    case '{}'
      expr=[expr '{'];
      expr=[expr num2str(index(j).subs{1})];
      for jj=2:length(index(j).subs),
        expr=[expr ',' num2str(index(j).subs{jj})];
      end
      expr=[expr '}'];
  end
end
%disp(['a' expr]);
b=eval(['a' expr]);
