import Flutter
import AVFoundation
import UIKit

public class MediaCompressorPlugin: NSObject, FlutterPlugin {
    private let videoQualityPresets: [String] = [
        "ultrafast",
        "superfast",
        "veryfast",
        "faster",
        "fast",
        "medium",
        "slow",
        "slower",
        "veryslow"
    ]
    
    private let supportedVideoFormats: [String] = [
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "3gp"
    ]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "media_compressor", binaryMessenger: registrar.messenger())
        let instance = MediaCompressorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "compressVideo":
            guard let args = call.arguments as? [String: Any],
                  let inputPath = args["inputPath"] as? String,
                  let outputPath = args["outputPath"] as? String else {
                result(FlutterError(code: "ERROR", message: "Invalid parameters", details: nil))
                return
            }
            
            let quality = (args["quality"] as? Int ?? 75).clamped(to: 0...100)
            let bitrate = (args["bitrate"] as? Int ?? 1000).clamped(to: 100...100000)
            let preset = args["preset"] as? String ?? "medium"
            let maxWidth = args["maxWidth"] as? Int
            let maxHeight = args["maxHeight"] as? Int

            DispatchQueue.global().async {
                do {
                    try self.compressVideo(
                        inputPath: inputPath,
                        outputPath: outputPath,
                        quality: quality,
                        bitrate: bitrate,
                        preset: preset,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight
                    )
                    result(outputPath)
                } catch {
                    result(FlutterError(code: "ERROR", message: "Video compression failed", details: error.localizedDescription))
                }
            }
        case "getAvailablePresets":
            result(videoQualityPresets)
        case "getSupportedFormats":
            result(supportedVideoFormats)
        case "isFormatSupported":
            guard let path = call.arguments as? String else {
                result(FlutterError(code: "ERROR", message: "Invalid path", details: nil))
                return
            }
            let extension = path.lowercased().split(separator: ".").last?.description ?? ""
            result(supportedVideoFormats.contains(extension))
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func compressVideo(
        inputPath: String,
        outputPath: String,
        quality: Int,
        bitrate: Int,
        preset: String,
        maxWidth: Int? = nil,
        maxHeight: Int? = nil
    ) throws {
        guard videoQualityPresets.contains(preset.lowercased()) else {
            throw NSError(domain: "MediaCompressor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid preset"])
        }

        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)

        // Remove existing output file if it exists
        try? FileManager.default.removeItem(at: outputURL)

        let asset = AVURLAsset(url: inputURL)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHEVC1920x1080)
        
        guard let exportSession = exportSession else {
            throw NSError(domain: "MediaCompressor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }

        // Configure video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoQualityKey: Float(quality) / 100.0,
            AVVideoAverageBitRateKey: bitrate * 1000,
            AVVideoMaxKeyFrameIntervalKey: 30
        ]

        // Configure video size if specified
        if let maxWidth = maxWidth, let maxHeight = maxHeight {
            let videoTrack = asset.tracks(withMediaType: .video).first
            let sourceSize = videoTrack?.naturalSize ?? CGSize(width: maxWidth, height: maxHeight)
            let targetSize = CGSize(
                width: min(CGFloat(maxWidth), sourceSize.width),
                height: min(CGFloat(maxHeight), sourceSize.height)
            )
            
            videoSettings[AVVideoWidthKey] = Int(targetSize.width)
            videoSettings[AVVideoHeightKey] = Int(targetSize.height)
        }

        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL
        exportSession.videoSettings = videoSettings

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                break
            case .failed:
                throw exportSession.error ?? NSError(domain: "MediaCompressor", code: 3, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
            case .cancelled:
                throw NSError(domain: "MediaCompressor", code: 4, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])
            default:
                break
            }
        }
    }
}

extension Int {
    func clamped(to limits: ClosedRange<Int>) -> Int {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
