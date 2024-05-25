import child_process from "node:child_process"
import { Ok, Error } from "./gleam.mjs"

export function execute(command, args) {
    const commandWithArgs = `${command} ${args.toArray().join(" ")}`

    try {
        return new Ok(child_process.execSync(commandWithArgs).toString())
    } catch (error) {
        return new Error([errorOutputToString(error), error.status])
    }
}

function errorOutputToString(error) {
    if (error.stdout != null) {
        return error.stdout.toString()
    }

    if (error.stderr != null) {
        return error.stderr.toString()
    }

    return ""
}
