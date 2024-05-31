import child_process from "node:child_process"
import process from "node:process"
import { default as operating_system } from "node:os"
import { Ok, Error } from "./gleam.mjs"
import { Some, None, is_some, unwrap } from "../gleam_stdlib/gleam/option.mjs"
import { Windows, Unix, Darwin, FreeBsd, OpenBsd, Linux, SunOs, OtherOs } from "./gleamyshell.mjs"

export function execute(command, args, workingDirectory) {
    const options = is_some(workingDirectory) ? { cwd: unwrap(workingDirectory) } : {}

    let result = {}

    try {
        result = child_process.spawnSync(command, args.toArray(), options)
    } catch {}

    return toResult(result)
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

function toResult(result) {
    if (result?.status === 0) {
        return new Ok(result.stdout?.toString() ?? "")
    }

    return result?.status == null
        ? new Error([result.error?.code ?? "", new None()])
        : new Error([result.stderr?.toString() ?? "", new Some(result.status)])
}
