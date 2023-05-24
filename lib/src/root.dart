import 'package:easy_downloader/easy_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';

import 'extract_url_info/domain/entities/video_entity.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final yt = YoutubeExplode();
  final dio = Dio();
  List<VideoEntity> videos = [];
  final TextEditingController _urlTextEditingController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text("header"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.url,
                    controller: _urlTextEditingController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print(_urlTextEditingController.text);
                    if (_urlTextEditingController.text.contains("list=")) {
                      final playlistDetail = await yt.playlists
                          .get(_urlTextEditingController.text);
                      print(playlistDetail.title);
                      final playlistVideos = await yt.playlists
                          .getVideos(playlistDetail.id)
                          .toList();
                      for (var playlistVideo in playlistVideos) {
                        print("=============================================");
                        print(
                            "?? ${playlistVideo.id} - ${playlistVideo.title}");
                        print(
                            "?? =============================================");
                        final videoFiles = await yt.videos.streamsClient
                            .getManifest(playlistVideo.id);

                        for (MuxedStreamInfo videoFile in videoFiles.muxed) {
                          print("?? ============================");
                          print(
                              "?? ${videoFile.size.totalMegaBytes.toStringAsFixed(2)} MB - ${videoFile.qualityLabel}");
                          final header =
                              await dio.head(videoFile.url.toString());
                          print("?? ${header.headers.value('Content-Type')}");
                        }
                        setState(() {
                          videos.add(
                            VideoEntity(
                                id: playlistVideo.id.toString(),
                                url: videoFiles.muxed.last.url.toString(),
                                title: playlistVideo.title,
                                size:
                                    "${videoFiles.muxed.last.size.totalMegaBytes.toStringAsFixed(2)} MB"),
                          );
                        });
                      }
                    } else {
                      final videoDetail =
                          await yt.videos.get(_urlTextEditingController.text);
                      print(videoDetail.id);
                      final videoFiles = await yt.videos.streamsClient
                          .getManifest(videoDetail.id);
                      for (MuxedStreamInfo videoFile in videoFiles.muxed) {
                        print("============================");
                        print(
                            "${videoFile.size.totalMegaBytes.toStringAsFixed(2)} MB - ${videoFile.qualityLabel}");
                        print(videoFile.url);
                      }
                    }
                    print("========done====");
                  },
                  child: const Text("Extract"),
                )
              ],
            ),
            Expanded(
                child: Center(
              child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      onTap: () async {
                        final download = await EasyDownloader().init(
                            clearLocaleStorage: true,
                            localeStoragePath:
                                (await getApplicationDocumentsDirectory())
                                    .path);
                        DownloadTask task = await download.download(
                          path: (await getApplicationDocumentsDirectory()).path,
                          url: videos[index].url,
                          maxSplit: 10,
                          fileName: "aa.mp4",
                          autoStart: true,
                        );
                        task.addListener((task) {
                          print(
                              (task.totalDownloaded / task.totalLength) * 100);
                        });
                        // await dio.download(
                        //   videos[index].url,
                        //   '${(await getDownloadsDirectory())!.path}/${videos[index].title}.mp4',
                        //   onReceiveProgress: (received, total) {
                        //     print((received / total) * 100);
                        //   },
                        // );
                        print(videos[index].url);
                      },
                      title: Text(videos[index].title),
                      subtitle: Text(videos[index].size),
                    );
                  }),
            ))
          ],
        ),
      ),
    );
  }
}
