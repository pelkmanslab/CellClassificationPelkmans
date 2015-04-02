function [ result ] = ismultiplate(value)
%ISMULTIPLATE Tells if multiplate mode is on or off.
%
%   Decides if project is configured to work in mutiplate mode.
%   Is overwritten by application setting (See File->Is multiplate?).
%   Note that since the inner value is persitent, it will be resetted only
%   after reloading MATLAB session.
%
persistent isMultiplate;

% By default, mutiplate mode is off. You can change it locally, but you
% should not commit it.
default = false;

if nargin==1
    % We are actually changing the mode.
    isMultiplate = value;
    return
end

if isempty(isMultiplate)
    % By default, mutiplate mode is off.
    isMultiplate = default;
end

result = isMultiplate;

end
