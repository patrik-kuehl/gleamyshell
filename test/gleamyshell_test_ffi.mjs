import process from "node:process"

export function setEnv(identifier, value) {
    process.env[identifier] = value

    return null
}

export function unsetEnv(identifier) {
    delete process.env[identifier]

    return null
}
