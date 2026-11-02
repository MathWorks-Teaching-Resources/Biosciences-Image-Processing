% Post-run checks for S3ProblemSetSoln.
testCase.verifyGreaterThanOrEqual(numcells, 8);
testCase.verifyLessThanOrEqual(numcells, 11);
testCase.verifyEqual(size(cent,1), numcells);
% <matlab:ShareFeedback Share your feedback>
