import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_app/constants/colors.dart';
import 'package:social_media_app/constants/dimens.dart';
import 'package:social_media_app/constants/strings.dart';
import 'package:social_media_app/constants/styles.dart';
import 'package:social_media_app/extensions/string_extensions.dart';
import 'package:social_media_app/global_widgets/avatar_widget.dart';
import 'package:social_media_app/global_widgets/circular_progress_indicator.dart';
import 'package:social_media_app/global_widgets/custom_app_bar.dart';
import 'package:social_media_app/global_widgets/custom_refresh_indicator.dart';
import 'package:social_media_app/global_widgets/keyboard_visibility_builder.dart';
import 'package:social_media_app/global_widgets/primary_icon_btn.dart';
import 'package:social_media_app/global_widgets/primary_text_btn.dart';
import 'package:social_media_app/global_widgets/typing_indicator_dots.dart';
import 'package:social_media_app/modules/chat/controllers/chat_controller.dart';
import 'package:social_media_app/modules/chat/controllers/single_chat_controller.dart';
import 'package:social_media_app/modules/chat/widgets/bubble_type.dart';
import 'package:social_media_app/modules/chat/widgets/chat_bubble_clipper.dart';
import 'package:social_media_app/modules/chat/widgets/chat_bubble_widget.dart';
import 'package:social_media_app/utils/utility.dart';

class SingleChatView extends StatelessWidget {
  const SingleChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: GetBuilder<SingleChatController>(
            builder: (logic) {
              if (!logic.initialized) {
                return const Center(child: NxCircularProgressIndicator());
              }
              return KeyboardVisibilityBuilder(
                builder: (_, child, isKeyboardVisible) {
                  if (isKeyboardVisible) {
                    logic.sendTypingStatus('start');
                  } else {
                    logic.sendTypingStatus('end');
                  }

                  return child;
                },
                child: SizedBox(
                  width: Dimens.screenWidth,
                  height: Dimens.screenHeight,
                  child: NxRefreshIndicator(
                    onRefresh: logic.fetchLatestMessages,
                    showProgress: false,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            NxAppBar(
                              padding: Dimens.edgeInsets8_16,
                              leading: Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          logic.username ?? '',
                                          style: AppStyles.style18Bold,
                                        ),
                                        GetBuilder<ChatController>(
                                            builder: (con) {
                                          final isUserOnline =
                                              con.isUserOnline(logic.userId!);
                                          if (isUserOnline) {
                                            return Text(
                                              'Online',
                                              style: AppStyles.style12Normal
                                                  .copyWith(
                                                color: ColorValues.successColor,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                      ],
                                    ),
                                    const Spacer(),
                                    // NxIconButton(
                                    //   icon: Icons.more_vert,
                                    //   iconColor: Theme.of(context)
                                    //       .textTheme
                                    //       .bodyText1!
                                    //       .color,
                                    //   onTap: () {},
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            Dimens.boxHeight8,
                            _buildBody(logic),
                          ],
                        ),
                        Positioned(
                          bottom: Dimens.zero,
                          left: Dimens.zero,
                          right: Dimens.zero,
                          child: Container(
                            color: Theme.of(Get.context!)
                                .dialogTheme
                                .backgroundColor,
                            width: Dimens.screenWidth,
                            height: Dimens.fourtyEight,
                            padding: Dimens.edgeInsets0_8,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                NxIconButton(
                                  icon: Icons.emoji_emotions_outlined,
                                  iconSize: Dimens.twentyFour,
                                  onTap: () {},
                                ),
                                Dimens.boxWidth8,
                                Expanded(
                                  child: TextFormField(
                                    controller: logic.messageTextController,
                                    onChanged: (value) =>
                                        logic.onChangedText(value),
                                    decoration: InputDecoration(
                                      hintText:
                                          StringValues.message.toTitleCase(),
                                      hintStyle:
                                          AppStyles.style14Normal.copyWith(
                                        color: Theme.of(Get.context!)
                                            .textTheme
                                            .subtitle1!
                                            .color,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    minLines: 1,
                                    maxLines: 1,
                                    style: AppStyles.style14Normal.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color,
                                    ),
                                  ),
                                ),
                                Dimens.boxWidth8,
                                if (logic.message.isNotEmpty)
                                  NxIconButton(
                                    icon: Icons.send,
                                    iconColor: ColorValues.primaryColor,
                                    iconSize: Dimens.twentyFour,
                                    onTap: logic.sendMessage,
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      NxIconButton(
                                        icon: Icons.attach_file_outlined,
                                        iconSize: Dimens.twentyFour,
                                        iconColor: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color,
                                        onTap: () {},
                                        //onTap: _showCreatePostOptions,
                                      )
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (logic.scrolledToBottom == false)
                          Positioned(
                            bottom: Dimens.hundred,
                            right: Dimens.sixTeen,
                            child: Container(
                              padding: Dimens.edgeInsets8,
                              decoration: const BoxDecoration(
                                  color: ColorValues.primaryColor,
                                  shape: BoxShape.circle),
                              child: NxIconButton(
                                icon: Icons.arrow_downward,
                                iconSize: Dimens.twentyFour,
                                iconColor: ColorValues.whiteColor,
                                onTap: logic.scrollToLast,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SingleChatController logic) {
    if (logic.isLoading) {
      return const Center(child: NxCircularProgressIndicator());
    }

    final currentUser = logic.profile.profileDetails!.user!;

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        reverse: true,
        controller: logic.scrollController,
        padding: Dimens.edgeInsets0_16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<ChatController>(
              builder: (chatsLogic) {
                chatsLogic.allMessages
                    .sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
                var filteredMessages = chatsLogic.allMessages
                    .where((element) =>
                        (element.senderId == currentUser.id &&
                            element.receiverId == logic.userId) ||
                        (element.senderId == logic.userId &&
                            element.receiver!.id == currentUser.id))
                    .toList();

                if (logic.scrolledToBottom) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    logic.markMessageAsRead();
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (logic.messageData!.hasNextPage!)
                      Center(
                        child: NxTextButton(
                          label: 'Load older messages',
                          onTap: () => logic.loadMore(),
                          labelStyle: AppStyles.style14Bold.copyWith(
                            color: ColorValues.primaryLightColor,
                          ),
                          padding: Dimens.edgeInsets8_0,
                        ),
                      ),
                    ListView.builder(
                      itemCount: filteredMessages.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final message = filteredMessages[index];
                        return ChatBubble(
                          message: message,
                        );
                      },
                    ),
                    if (chatsLogic.isUserTyping(logic.userId!))
                      Dimens.boxHeight8,
                    if (chatsLogic.isUserTyping(logic.userId!))
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AvatarWidget(
                            avatar: logic.profileImage,
                            size: Dimens.sixTeen,
                          ),
                          PhysicalShape(
                            elevation: Dimens.two,
                            clipper: ChatBubbleClipper(
                              radius: Dimens.eight,
                              type: BubbleType.receiverBubble,
                            ),
                            color: Theme.of(Get.context!).dialogBackgroundColor,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: Dimens.eight,
                                bottom: Dimens.sixTeen,
                                left: Dimens.sixTeen,
                                right: Dimens.eight,
                              ),
                              child: TypingIndicator(
                                showIndicator:
                                    chatsLogic.isUserTyping(logic.userId!),
                              ),
                            ),
                          )
                        ],
                      ),
                  ],
                );
              },
            ),
            Dimens.boxHeight60,
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() => AppUtility.showBottomSheet(
        [
          ListTile(
            onTap: () {
              AppUtility.closeBottomSheet();
              //CreatePostController.find.captureImage();
            },
            leading: const Icon(Icons.camera),
            title: Text(
              StringValues.captureImage,
              style: AppStyles.style16Bold,
            ),
          ),
          ListTile(
            onTap: () {
              AppUtility.closeBottomSheet();
              //CreatePostController.find.recordVideo();
            },
            leading: const Icon(Icons.videocam),
            title: Text(
              StringValues.recordVideo,
              style: AppStyles.style16Bold,
            ),
          ),
          ListTile(
            onTap: () {
              AppUtility.closeBottomSheet();
              // CreatePostController.find.selectPostImages();
            },
            leading: const Icon(Icons.photo_album),
            title: Text(
              StringValues.chooseImages,
              style: AppStyles.style16Bold,
            ),
          ),
          ListTile(
            onTap: () {
              AppUtility.closeBottomSheet();
              // CreatePostController.find.selectPosVideos();
            },
            leading: const Icon(Icons.video_collection),
            title: Text(
              StringValues.chooseVideos,
              style: AppStyles.style16Bold,
            ),
          ),
        ],
      );
}
