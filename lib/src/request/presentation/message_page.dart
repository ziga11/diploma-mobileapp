import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/request/application/request_controller.dart';
import 'package:diplomaapp/src/request/data/request_repository.dart';
import 'package:diplomaapp/src/request/domain/request.dart';
import 'package:diplomaapp/src/request/domain/request_type_enum.dart';
import 'package:diplomaapp/src/request/presentation/widgets/document_navigation.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/domain/message_content.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/lotus_loading.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:diplomaapp/src/utils/other.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';

class MessagePage extends StatefulWidget {
  static const route = "/message-page";
  final int reqId;

  const MessagePage({super.key, required this.reqId});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final textController = TextEditingController();
  final requestController = RequestController();

  final tFocusNode = FocusNode();

  FilePickerResult? result;
  List<Message> thread = [];

  Map<String, String> translations =
      getIt<LanguageService>().translations.value;
  late Future<List<Message>> fetchThread;

  final mRepo = getIt<MessageRepository>();

  final user = getIt<UserService>().currentUser!;
  final infoUser = getIt<UserService>().infoUser.value!;

  @override
  void initState() {
    super.initState();
    fetchThread = mRepo.fetchThread(widget.reqId, user.id);
    mRepo.setRead(widget.reqId, user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DiplomaAppbar(
        leading: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            BackButton(
              color: ColorTheme.white,
            ),
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu_rounded))
          ],
        ),
      ),
      drawer: const DiplomaDrawer(),
      body: ValueListenableBuilder(
          valueListenable: getIt<LanguageService>().translations,
          builder: (context, t, _) {
            translations = t;
            return Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                      future: fetchThread,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: AnimatedLotusLoader(
                            size: 96,
                          ));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(translations["errorOccurred"]!),
                          );
                        } else if (!snapshot.hasData) {
                          return Text("No content");
                        }
                        thread = snapshot.data!;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          itemCount: thread.length,
                          itemBuilder: (context, index) {
                            final entity = thread[index];
                            final isMe = entity.sender.id == user.id;

                            if (index == 0 &&
                                !entity.read! &&
                                entity.recipient == user) {
                              mRepo.setRead(widget.reqId, user.id);
                            }

                            return _buildChatBubble(entity, isMe);
                          },
                        );
                      }),
                ),
                TapRegion(
                    onTapOutside: (_) {
                      tFocusNode.unfocus();
                    },
                    child: _buildInputArea()),
              ],
            );
          }),
    );
  }

  Widget _buildChatBubble(Message entity, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
            minWidth: width(context) * 0.4, maxWidth: width(context) * 0.8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? ColorTheme.primaryColor.withValues(alpha: 0.9)
              : ColorTheme.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: Border.all(color: ColorTheme.white.withValues(alpha: 0.2)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe
                      ? capitalize(translations["me"]!)
                      : '${entity.sender.firstName} ${entity.sender.lastName}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? ColorTheme.white.withValues(alpha: 0.8)
                          : ColorTheme.secondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  entity.getMessageContent().title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entity.getMessageContent().text,
                  style: TextStyle(color: ColorTheme.white, fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (entity.documentIDs?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: DocumentNavgiation(
                      documentIDs: entity.documentIDs!,
                      leftFileAlignment: !isMe,
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: isMe ? 0 : null,
              left: isMe ? null : 0,
              child: Text(
                formatDateTime(entity.date!),
                style: TextStyle(
                  fontSize: 10,
                  color: ColorTheme.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding:
          EdgeInsets.fromLTRB(8, 8, 16, MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: ColorTheme.bgDark.withValues(alpha: 0.2),
        border: Border(
            top:
                Border.all(color: ColorTheme.white.withValues(alpha: 0.1)).top),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: ColorTheme.white),
            onPressed: () async {
              result = await FilePicker.platform.pickFiles(allowMultiple: true);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                focusNode: tFocusNode,
                controller: textController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: translations["typeMessage"],
                  hintStyle:
                      TextStyle(color: ColorTheme.white.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ColorTheme.primaryColor,
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: ColorTheme.white, size: 20),
              onPressed: () async {
                final lastMsg = thread.last;

                Message msg = Message(
                  parentMsgId: lastMsg.id,
                  messageContent: {
                    getIt<LanguageService>().current.code:
                        MessageContent(title: textController.text, text: "")
                  },
                  date: DateTime.now(),
                  sender: user,
                  recipient: infoUser,
                  threadTS: lastMsg.threadTS,
                );

                thread.add(msg);
                setState(() {});

                textController.clear();

                await requestController
                    .sendRequest(
                  requestType: RequestType.other,
                  msg: msg,
                  files: result?.files,
                )
                    .then((mId) async {
                  msg.id = mId;
                  if (result == null || result!.files.isEmpty) return;

                  final index = thread.indexOf(msg);
                  final newMsgs = await mRepo.fetchMessages(user.id, mId: mId);
                  if (newMsgs == null) return;

                  thread.removeAt(index);
                  thread.insert(index, newMsgs[0]);
                });

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
