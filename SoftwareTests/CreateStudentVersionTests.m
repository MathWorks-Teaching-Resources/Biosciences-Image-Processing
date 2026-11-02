classdef CreateStudentVersionTests < matlab.unittest.TestCase
    %CreateStudentVersionTests - Check startup apps and learner distribution
    %   CreateStudentVersionTests verifies the module presentation and a
    %   temporary learner export without publishing or changing the source.
    %
    %   See also CreateStudentVersionHelper, matlab.unittest.TestCase

    properties (Access = private)
        ProjectRoot
    end

    methods (TestMethodSetup)
        function locateProject(testCase)
            testCase.ProjectRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(testCase.ProjectRoot, 'InstructorResources', ...
                'HelperFunctions')));
        end
    end

    methods (Test)
        function facultyStartupShowsModule(testCase)
            app = ProjectStartupApp;
            testCase.addTeardown(@() delete(app));
            drawnow
            testCase.verifyTrue(contains(app.HTML5.HTMLSource, ...
                'Biological Sciences: Image Processing'));
            testCase.verifyEqual(string(app.Image2.ImageSource), ...
                string(fullfile(testCase.ProjectRoot, 'Images', ...
                'FluorescentCells.jpg')));
            testCase.verifyNotEmpty(app.InstructorButton);
            testCase.verifyEqual(app.StartUpAppUIFigure.Visible, ...
                matlab.lang.OnOffSwitchState.on);
        end

        function studentStartupShowsModule(testCase)
            app = ProjectStartupAppStudent;
            testCase.addTeardown(@() delete(app));
            drawnow
            testCase.verifyTrue(contains(app.HTML5.HTMLSource, ...
                'Biological Sciences: Image Processing'));
            testCase.verifyEqual(string(app.Image2.ImageSource), ...
                string(fullfile(testCase.ProjectRoot, 'Images', ...
                'FluorescentCells.jpg')));
            testCase.verifyEmpty(app.InstructorButton);
        end

        function startupMenuOpens(testCase)
            app = ProjectStartupApp;
            testCase.addTeardown(@() delete(app));
            document = matlab.desktop.editor.openDocument( ...
                fullfile(testCase.ProjectRoot, 'MainMenu.m'), Visible=0);
            testCase.addTeardown(@() document.closeNoPrompt);
            feval(app.MainMenuButton.ButtonPushedFcn, app.MainMenuButton, []);
            drawnow
            testCase.verifyEqual(string(document.Filename), ...
                string(fullfile(testCase.ProjectRoot, 'MainMenu.m')));
            testCase.verifyFalse(isvalid(app));
        end

        function siblingExportContainsOnlyStudentMaterials(testCase)
            destination = string(tempname) + '-Student';
            testCase.addTeardown(@() removeTestExport(destination));
            outputFolder = CreateStudentVersionHelper('export', ...
                Destination=destination);
            testCase.verifyEqual(outputFolder, destination);
            testCase.verifyTrue(isfile(fullfile(destination, ...
                'BiosciencesImageProcessing.prj')));
            testCase.verifyTrue(isfile(fullfile(destination, 'GettingStarted.pdf')));
            testCase.verifyTrue(isfile(fullfile(destination, 'LICENSE.md')));
            testCase.verifyTrue(isfile(fullfile(destination, 'SECURITY.md')));
            testCase.verifyFalse(isfolder(fullfile(destination, 'InstructorResources')));
            testCase.verifyFalse(isfolder(fullfile(destination, 'InternalFiles')));
            testCase.verifyFalse(isfolder(fullfile(destination, 'SoftwareTests')));
            testCase.verifyFalse(isfolder(fullfile(destination, '.github')));
            testCase.verifyFalse(isfolder(fullfile(destination, '.cache')));
            testCase.verifyFalse(isfile(fullfile(destination, 'buildfile.m')));
            testCase.verifyFalse(isfile(fullfile(destination, 'Utilities', ...
                'ProjectStartupAppStudent.m')));
            testCase.verifyFalse(contains(fileread(fullfile(destination, ...
                'MainMenu.m')), 'InstructorResources/'));
            testCase.verifyTrue(contains(fileread(fullfile(destination, ...
                'Utilities', 'ProjectStartupApp.m')), ...
                'HideInstructorResources = true;'));
            testCase.addTeardown(@() restoreSourceProject(testCase.ProjectRoot));
            studentProject = openProject(fullfile(destination, ...
                'BiosciencesImageProcessing.prj'));
            testCase.verifyEqual(string(studentProject.RootFolder), destination);
            testCase.verifyFalse(any(contains(studentProject.PathFolders, ...
                'SoftwareTests')));
            testCase.verifyTrue(isfolder(fullfile(testCase.ProjectRoot, ...
                'InstructorResources')));
        end

        function exportRejectsSourceDirectory(testCase)
            testCase.verifyError(@() CreateStudentVersionHelper('export', ...
                Destination=string(testCase.ProjectRoot)), ...
                'CreateStudentVersionHelper:UnsafeDestination');
        end

        function exportRejectsExistingDestination(testCase)
            testCase.verifyError(@() CreateStudentVersionHelper('export', ...
                Destination=string(tempdir)), ...
                'CreateStudentVersionHelper:DestinationExists');
        end
    end
end

function restoreSourceProject(projectRoot)
openProject(fullfile(projectRoot, 'BiosciencesImageProcessing.prj'));
delete(findall(groot, 'Name', 'StartUp App'))
end

function removeTestExport(destination)
% Delete only this test's unique directory directly under the temp folder.
assert(strcmpi(fileparts(destination), strip(string(tempdir), 'right', filesep)), ...
    'Test export cleanup must stay within the temporary directory.');
if isfolder(destination)
    rmdir(destination, 's')
end
end
