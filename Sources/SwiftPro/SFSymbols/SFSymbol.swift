import Foundation

public extension SFSymbol {
    static func symbol(forFileURL fileURL: URL) -> SFSymbol {
        let fileExtension = fileURL.pathExtension.lowercased()

        return switch fileExtension {
        case "doc", "docx": .docFill
        case "xls", "xlsx": .tablecellsFill
        case "ppt", "pptx": .rectangleFillOnRectangleAngledFill
        case "pdf": .docRichtextFill
        case "txt": .textAlignleft
        case "jpg", "jpeg": .photoFill
        case "png": .photoOnRectangleAngled
        case "gif": .livephoto
        case "mp3": .musicQuarternote3
        case "wav": .waveformPathEcg
        case "mp4", "mov": .filmFill
        case "zip", "rar": .archiveboxFill
        case "html": .scrollFill
        default: .folderBadgeQuestionmark
        }
    }

    // /// Находит символ, наиболее похожий на заданную входную строку.
    // /// Этот метод просматривает все значения `SFSymbol`, чтобы найти символ
    // /// имя которого имеет минимальное расстояние Левенштейна до входной строки.
    // ///
    // /// - Ввод параметра: строка для сравнения с именами символов.
    // /// - Возвращает: `SFSymbol`, наиболее похожий на предоставленную входную строку.
    // /// Возвращает `nil`, если нет символов (маловероятно в практических сценариях).
    @Sendable static func findSymbol(by input: String) async -> SFSymbol? {
        guard input.isEmpty == false else { return nil }
        
        return await Task { () async -> SFSymbol? in await MLSymbolFinder.findMostSimilarSymbol(to: input) }.value
    }
  
}
