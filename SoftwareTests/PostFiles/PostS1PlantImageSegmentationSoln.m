% Post-run checks for S1PlantImageSegmentationSoln.
testCase.verifyNotEmpty(diam_cm);
testCase.verifyGreaterThan(diam_cm, 0);
testCase.verifyTrue(all(isfinite(diam_cm)));
testCase.verifyGreaterThanOrEqual(propsTable.Area, 8000);
testCase.verifyLessThanOrEqual(propsTable.Area, 22500);
testCase.verifyEqual(avg_flowerspan, mean(diam_cm), AbsTol=1e-12);
% <matlab:ShareFeedback Share your feedback>
