import 'enum.dart';
import 'nim_message_model.dart';

class NIMHistoryMessageSearchOption {
  int startTime;
  int limit;
  int endTime;
  bool nimSync;
  List<int> messageTypes;
  NIMMessageSearchOrder order;
  NIMMessage currentMessage;

  NIMHistoryMessageSearchOption(
      {this.startTime,
      this.limit,
      this.endTime,
      this.nimSync,
      this.messageTypes,
      this.order,
      this.currentMessage});

  NIMHistoryMessageSearchOption.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    limit = json['limit'];
    endTime = json['endTime'];
    nimSync = json['sync'];
    messageTypes = json['messageTypes'].cast<int>();
    order = json['order'];
    currentMessage = json['currentMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = this.startTime;
    data['limit'] = this.limit;
    data['endTime'] = this.endTime;
    data['sync'] = this.nimSync;
    data['messageTypes'] = this.messageTypes;
    data['order'] = this.order;
    data['currentMessage'] = this.currentMessage;
    return data;
  }
}
