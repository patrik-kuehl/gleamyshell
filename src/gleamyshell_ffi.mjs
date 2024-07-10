import child_process from "node:child_process"
import process from "node:process"
import { default as operating_system } from "node:os"
import { Ok, Error, isEqual } from "./gleam.mjs"
import { Windows, Unix, Darwin, FreeBsd, OpenBsd, Linux, SunOs, OtherOs, CommandOutput } from "./gleamyshell.mjs"

export function execute(executable, workingDirectory, args) {
    if (isEqual(which(executable), new Error(null))) {
        return new Error("enoent")
    }

    return spawnSync(executable, args.toArray(), workingDirectory)
}

export function cwd() {
    try {
        return new Ok(process.cwd())
    } catch {
        return new Error(null)
    }
}

export function os() {
    const operatingSystem = process.platform

    switch (operatingSystem) {
        case "win32":
            return new Windows()
        case "darwin":
            return new Unix(new Darwin())
        case "freebsd":
            return new Unix(new FreeBsd())
        case "openbsd":
            return new Unix(new OpenBsd())
        case "linux":
            return new Unix(new Linux())
        case "sunos":
            return new Unix(new SunOs())
        default:
            return new Unix(new OtherOs(operatingSystem))
    }
}

export function homeDirectory() {
    try {
        return new Ok(operating_system.homedir())
    } catch {
        return new Error(null)
    }
}

export function env(identifier) {
    const value = process.env[identifier]

    return value == null ? new Error(null) : new Ok(value)
}

export function which(executable) {
    const windowsArgs = ["powershell", `(gcm ${executable}).Path`]
    const unixArgs = ["which", executable]

    const result = isEqual(os(), new Windows())
        ? spawnSync(windowsArgs[0], [windowsArgs[1]], ".")
        : spawnSync(unixArgs[0], [unixArgs[1]], ".")

    const output = result[0].output.trim()

    return result[0].exit_code === 0 && output !== "" ? new Ok(output) : new Error(null)
}

function spawnSync(executable, args, workingDirectory) {
    let result = {}

    try {
        result =
            typeof Bun !== "undefined"
                ? Bun.spawnSync([executable, ...args], { cwd: workingDirectory, env: process.env })
                : child_process.spawnSync(executable, args, { cwd: workingDirectory })

        if (result.exitCode != null) {
            result.status = result.exitCode
        }
    } catch (error) {
        return new Error(error.toString())
    }

    if (result.error?.code != null) {
        return new Error(result.error.code.toLowerCase())
    }

    return new Ok(
        new CommandOutput(result.status, result.status === 0 ? result.stdout.toString() : result.stderr.toString()),
    )
}
