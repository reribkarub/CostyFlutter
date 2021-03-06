import 'package:bloc_test/bloc_test.dart';
import 'package:costy/data/errors/failures.dart';
import 'package:costy/data/models/currency.dart';
import 'package:costy/data/models/project.dart';
import 'package:costy/data/usecases/impl/add_project.dart';
import 'package:costy/data/usecases/impl/delete_project.dart';
import 'package:costy/data/usecases/impl/get_projects.dart';
import 'package:costy/data/usecases/impl/modify_project.dart';
import 'package:costy/presentation/bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetProjects extends Mock implements GetProjects {}

class MockAddProject extends Mock implements AddProject {}

class MockDeleteProject extends Mock implements DeleteProject {}

class MockModifyProject extends Mock implements ModifyProject {}

void main() {
  MockGetProjects mockGetProjects;
  MockAddProject mockAddProject;
  MockDeleteProject mockDeleteProject;
  MockModifyProject mockModifyProject;

  ProjectBloc bloc;

  setUp(() {
    mockGetProjects = MockGetProjects();
    mockAddProject = MockAddProject();
    mockDeleteProject = MockDeleteProject();
    mockModifyProject = MockModifyProject();

    bloc = ProjectBloc(
        addProject: mockAddProject,
        deleteProject: mockDeleteProject,
        getProjects: mockGetProjects,
        modifyProject: mockModifyProject);
  });

  const tProjectName = 'Sample project.';
  const tProjectDefaultCurrency = Currency(name: 'USD');

  final tCreationDateTime = DateTime(2020, 1, 1, 10, 10, 10);
  final tProjectsList = [
    Project(
        id: 1,
        name: 'First',
        defaultCurrency: const Currency(name: 'USD'),
        creationDateTime: tCreationDateTime),
    Project(
        id: 2,
        name: 'Second',
        defaultCurrency: const Currency(name: 'USD'),
        creationDateTime: tCreationDateTime)
  ];

  blocTest('should emit proper states when getting projects',
      skip: 0,
      build: () {
        when(mockGetProjects.call(any))
            .thenAnswer((_) async => Right(tProjectsList));
        return bloc;
      },
      act: (bloc) => bloc.add(GetProjectsEvent()),
      expect: [ProjectLoading(), ProjectLoaded(tProjectsList)]);

  blocTest('should emit proper states in case of error when getting projects',
      build: () {
        when(mockGetProjects.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetProjectsEvent()),
      expect: [ProjectLoading(), const ProjectError(datasouceFailureMessage)]);

  blocTest('should emit proper states when adding project',
      build: () {
        when(mockAddProject.call(any))
            .thenAnswer((_) async => Right(tProjectsList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddProjectEvent(
          projectName: tProjectName, defaultCurrency: tProjectDefaultCurrency)),
      expect: [ProjectLoading(), ProjectAdded(tProjectsList[0].id)]);

  blocTest('should emit proper states in case of error when adding project',
      build: () {
        when(mockAddProject.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddProjectEvent(
          projectName: tProjectName, defaultCurrency: tProjectDefaultCurrency)),
      expect: [ProjectLoading(), const ProjectError(datasouceFailureMessage)]);

  blocTest('should emit proper states when deleting project',
      build: () {
        when(mockDeleteProject.call(any))
            .thenAnswer((_) async => Right(tProjectsList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProjectEvent(tProjectsList[0].id)),
      expect: [ProjectLoading(), ProjectDeleted(tProjectsList[0].id)]);

  blocTest('should emit proper states in case of error when deleting project',
      build: () {
        when(mockDeleteProject.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProjectEvent(tProjectsList[0].id)),
      expect: [ProjectLoading(), const ProjectError(datasouceFailureMessage)]);

  blocTest('should emit proper states when modifying project',
      build: () {
        when(mockModifyProject.call(any))
            .thenAnswer((_) async => Right(tProjectsList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyProjectEvent(tProjectsList[0])),
      expect: [ProjectLoading(), ProjectModified(tProjectsList[0].id)]);

  blocTest('should emit proper states in case of error when modifying project',
      build: () {
        when(mockModifyProject.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyProjectEvent(tProjectsList[0])),
      expect: [ProjectLoading(), const ProjectError(datasouceFailureMessage)]);
}
