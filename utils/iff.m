function [varargout] = iff(cond, evalTrue, evalFalse)
%IFF 'if' expression implementation
%   v = IFF(cond, evalTrue, evalFalse) returns 'evalTrue' if 'cond' is true,
%   otherwise returns 'evalFalse'. 
%
%   This enables you to write succint one-liners like:
%   signstr = iff(x > 0, 'positive', 'negative');
%
%   Either of 'evalTrue' or 'evalFalse' can be functions, in which case
%   the result of their execution is returned, but only the returned one
%   will be executed. This allows for evaluations which only make sense
%   depedent on the condition, e.g.:
%   added = iff(ischar(x), @() [x x], @() x + x)
%
% Part of Burgbox

% 2013-01 CB created

if isa(cond, 'function_handle')
  cond = cond();
end
if cond
  result = evalTrue;
else
  result = evalFalse;
end

if isa(result, 'function_handle')
  if nargout == 0 || nargout(result) == 0
    result();
    varargout = {};
  else
    [varargout{1:nargout}] = result();
  end
else
  varargout = {result};
end

end

