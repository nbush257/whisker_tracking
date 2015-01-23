function [A,fval] = fitPolyWhisker(x,y)
% function [A,fval] = fitPolyWhisker(x,y)
%
% This function fits a polynomial of the form y = A1x^4 + A2x^3 + A3x^2, given inputs A
% (scalar coefficients) and a vector of real numbers, x.
% Then, it compares the fitted y values (y_fit) to the actual y values
% given in the input to the function, and computes the sum squared error
% (SSE) and calls fminsearch to fit optimized parameters to A.
%
% John Sheppard, 4 November 2014

[A,fval] = fminsearch(@getQuadraticSSE,[0 0 0]);

    function SSE = getQuadraticSSE(A)
        
        SSE = sum( (y - (A(1)*x.^4 + A(2)*x.^3 + A(3)*x.^2)) .^2 );
        
    end
end
