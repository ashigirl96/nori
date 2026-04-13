import Foundation

struct RemoteRelayZshBootstrap {
    let shellStateDir: String

    private var sharedHistoryLines: [String] {
        [
            "if [ -z \"${HISTFILE:-}\" ] || [ \"$HISTFILE\" = \"\(shellStateDir)/.zsh_history\" ]; then export HISTFILE=\"$NORI_REAL_ZDOTDIR/.zsh_history\"; fi",
        ]
    }

    var zshEnvLines: [String] {
        [
            "[ -f \"$NORI_REAL_ZDOTDIR/.zshenv\" ] && source \"$NORI_REAL_ZDOTDIR/.zshenv\"",
            "if [ -n \"${ZDOTDIR:-}\" ] && [ \"$ZDOTDIR\" != \"\(shellStateDir)\" ]; then export NORI_REAL_ZDOTDIR=\"$ZDOTDIR\"; fi",
        ] + sharedHistoryLines + [
            "export ZDOTDIR=\"\(shellStateDir)\"",
        ]
    }

    var zshProfileLines: [String] {
        [
            "[ -f \"$NORI_REAL_ZDOTDIR/.zprofile\" ] && source \"$NORI_REAL_ZDOTDIR/.zprofile\"",
        ]
    }

    func zshRCLines(commonShellLines: [String]) -> [String] {
        sharedHistoryLines + [
            "[ -f \"$NORI_REAL_ZDOTDIR/.zshrc\" ] && source \"$NORI_REAL_ZDOTDIR/.zshrc\"",
        ] + commonShellLines
    }

    var zshLoginLines: [String] {
        [
            "[ -f \"$NORI_REAL_ZDOTDIR/.zlogin\" ] && source \"$NORI_REAL_ZDOTDIR/.zlogin\"",
        ]
    }
}
