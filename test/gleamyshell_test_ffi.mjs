import process from "node:process"

export function unsetEnv(identifier) {
    delete process.env[identifier]

    return null
}
