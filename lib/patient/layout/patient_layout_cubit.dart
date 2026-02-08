import 'package:flutter_bloc/flutter_bloc.dart';

class PatientLayoutCubit extends Cubit<int> {
  PatientLayoutCubit() : super(0);

  void selectTab(int index) {
    if (state != index) {
      emit(index);
    }
  }
}
