import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padaria_sustentavel_app/ui/pages/product_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// Event
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadMonths extends HomeEvent {}

// State
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<String> months;

  const HomeLoaded(this.months);

  @override
  List<Object> get props => [months];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadMonths>(_onLoadMonths);
  }

  Future<void> _onLoadMonths(LoadMonths event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final monthKeys = keys.where((key) => key.startsWith('data_')).toList();
      final months =
          monthKeys.map((key) => key.replaceFirst('data_', '')).toList();
      emit(HomeLoaded(months));
    } catch (e) {
      emit(const HomeError('Erro ao carregar os meses'));
    }
  }
}

// HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadMonths()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 12.0),
              child: Image.asset(
                'assets/images/logo.png',
                height: 64,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeLoaded) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.months.length,
                    itemBuilder: (context, index) {
                      final month = state.months[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductListScreen(month: month),
                            ),
                          );
                        },
                        child: Card(
                          child: Center(
                            child: Text(
                              month,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is HomeError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('Nenhum mês salvo'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
