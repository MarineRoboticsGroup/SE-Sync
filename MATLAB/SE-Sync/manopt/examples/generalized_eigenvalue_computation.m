function [Xsol, Ssol] = generalized_eigenvalue_computation(A, B, p)
% Returns orthonormal basis of the dominant invariant p-subspace of B^-1 A.
%
% function [Xsol, Ssol] = generalized_eigenvalue_computation(A, B, p)
%
% Input: A is a real, symmetric matrix of size nxn,
%        B is a symmetric positive definite matrix, same size as A, and
%        an integer p < n.
% Output: Xsol: a real, orthonormal matrix X of size nxp such that
%         trace(X'*A*X) is maximized, subject to X'*B*X being identity. 
%         That is, the columns of X form an orthonormal basis of a dominant
%         subspace of dimension p of B^(-1)*A. These are thus eigenvectors
%         associated with the largest eigenvalues of B^(-1)*A  (in no
%         particular order). Sign is important: 2 is deemed a larger
%         eigenvalue than -5.
%         Ssol: the eigenvalues associated with the eigenvectors Xsol.
% 
% We intend to solve the homogeneous system A*X = B*X*S,
% where S is a diagonal matrix of dominant eigenvalues of B^-1 A.
%
%
% The optimization is performed on the generalized Grassmann manifold, 
% since only the space spanned by the columns of X matters. 
%
% The optimization problem that we are solving here is 
% maximize trace(X'*A*X) subject to X'*B*X = eye(p). 
% Consequently, the solutions remain invariant to transformation
% X --> XO, where O is a p-by-p orthogonal matrix. The search space, in
% essence, is set of equivalence classes
% [X] = {XO : X'*B*X = I and O is orthogonal matrix}. This space is called
% the generalized Grassmann manifold.
%
% See also dominant_invariant_subspace nonlinear_eigenspace


% This file is part of Manopt and is copyrighted. See the license file.
%
% Main author: Bamdev Mishra, June 30, 2015.
% Contributors:
% Change log:
    
    % Generate some random data to test the function
    if ~exist('A', 'var') || isempty(A)
        n = 128;
        A = randn(n);
        A = (A+A')/2;
    end
    if ~exist('B', 'var') || isempty(B)
        n = size(A, 1);
        e = ones(n, 1);
        B = spdiags([-e 2*e -e], -1:1, n, n); % Symmetric positive definite
    end
    
    if ~exist('p', 'var') || isempty(p)
        p = 3;
    end
    
    % Make sure the input matrix is square and symmetric
    n = size(A, 1);
	assert(isreal(A), 'A must be real.')
    assert(size(A, 2) == n, 'A must be square.');
    assert(norm(A-A', 'fro') < n*eps, 'A must be symmetric.');
	assert(p <= n, 'p must be smaller than n.');
    
    % Define the cost and its derivatives on the generalized 
    % Grassmann manifold, i.e., the column space of all X such that
    % X'*B*X is identity. 
    gGr = grassmanngeneralizedfactory(n, p, B);
    
    problem.M = gGr;
    problem.cost  = @(X)    -trace(X'*A*X);
    problem.egrad = @(X)    -2*(A*X); % Only Euclidean gradient needed.
    problem.ehess = @(X, H) -2*(A*H); % Only Euclidean Hessian needed.
    
    % Execute some checks on the derivatives for early debugging.
    % These things can be commented out of course.
    % checkgradient(problem);
    % pause;
    % checkhessian(problem);
    % pause;
    
    % Issue a call to a solver. A random initial guess will be chosen and
    % default options are selected except for the ones we specify here.
    options.Delta_bar = 8*sqrt(p);
    [Xsol, costXsol, info] = trustregions(problem, [], options); %#ok<NASGU,ASGLU>
    
    % To extract the eigenvalues, solve the small p-by-p symmetric 
    % eigenvalue problem.
    Ssol = eig(Xsol'*(A*Xsol));
  
end
