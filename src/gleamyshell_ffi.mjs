import child_process from "node:child_process"
import process from "node:process"
import { default as operating_system } from "node:os"
import { Ok, Error, isEqual } from "./gleam.mjs"
import {
    Windows,
    Unix,
    Darwin,
    FreeBsd,
    OpenBsd,
    Linux,
    SunOs,
    OtherOs,
    Failure,
    Abort,
    Enomem,
    Eagain,
    Enametoolong,
    Emfile,
    Enfile,
    Eacces,
    Enoent,
    OtherAbortReason,
} from "./gleamyshell.mjs"

export function execute(executable, workingDirectory, args) {
    if (isEqual(which(executable), new Error(null))) {
        return new Error(new Abort(new Enoent()))
    }

    return childProcessResultToGleamResult(spawnSync(executable, args.toArray(), workingDirectory))
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

    let result = isEqual(os(), new Windows())
        ? spawnSync(windowsArgs[0], [windowsArgs[1]], ".")
        : spawnSync(unixArgs[0], [unixArgs[1]], ".")

    return result.status === 0 && result.stdout != null && result.stdout.toString().trim() !== ""
        ? new Ok(result.stdout.toString().trim())
        : new Error(null)
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
    } catch {}

    return result
}

function childProcessResultToGleamResult(result) {
    if (result.status === 0) {
        return new Ok(result.stdout?.toString() ?? "")
    }

    if (result.status != null) {
        return new Error(new Failure(result.stderr?.toString() ?? "", result.status))
    }

    const error_code = result.error?.code ?? ""

    switch (error_code) {
        case "ENOMEM":
            return new Error(new Abort(new Enomem()))
        case "EAGAIN":
            return new Error(new Abort(new Eagain()))
        case "ENAMETOOLONG":
            return new Error(new Abort(new Enametoolong()))
        case "EMFILE":
            return new Error(new Abort(new Emfile()))
        case "ENFILE":
            return new Error(new Abort(new Enfile()))
        case "EACCES":
            return new Error(new Abort(new Eacces()))
        default:
            return new Error(new Abort(new OtherAbortReason(error_code)))
    }
}
