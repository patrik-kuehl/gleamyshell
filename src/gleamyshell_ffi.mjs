import child_process from "node:child_process"
import process from "node:process"
import { default as operating_system } from "node:os"
import { Ok, Error, isEqual } from "./gleam.mjs"
import { Some, None } from "../gleam_stdlib/gleam/option.mjs"
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
    let result = {}

    try {
        result = child_process.spawnSync(executable, args.toArray(), { cwd: workingDirectory })
    } catch {}

    return childProcessResultToGleamResult(result)
}

export function cwd() {
    try {
        return new Some(process.cwd())
    } catch {
        return new None()
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
        return new Some(operating_system.homedir())
    } catch {
        return new None()
    }
}

export function env(identifier) {
    const value = process.env[identifier]

    return value == null ? new None() : new Some(value)
}

export function setEnv(identifier, value) {
    process.env[identifier] = value

    return process.env[identifier] != null
}

export function unsetEnv(identifier) {
    delete process.env[identifier]

    return process.env[identifier] == null
}

export function which(executable) {
    let result = {}

    try {
        if (isEqual(os(), new Windows())) {
            result = child_process.spawnSync("powershell", [`(gcm ${executable}).Path`])
        } else {
            result = child_process.spawnSync("which", [executable])
        }
    } catch {}

    return result.status === 0 && result.stdout != null && result.stdout.toString().trim() !== ""
        ? new Some(result.stdout.toString().trim())
        : new None()
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
        case "ENOENT":
            return new Error(new Abort(new Enoent()))
        default:
            return new Error(new Abort(new OtherAbortReason(error_code)))
    }
}
