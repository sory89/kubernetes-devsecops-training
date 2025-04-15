package main

secrets_env = [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny[msg] {
    some i
    input[i].Cmd == "env"
    val := input[i].Value
    some j
    contains(lower(val[j]), secrets_env[_])
    msg := sprintf("Line %d: Potential secret in ENV key found: %s", [i, val])
}

# Do not use 'latest' tag for base image
deny[msg] {
    some i
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    count(val) > 1
    lower(val[1]) == "latest"
    msg := sprintf("Line %d: do not use 'latest' tag for base images", [i])
}

# Avoid curl bashing
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.find_n("(curl|wget)[^|^>]*[|>]", lower(val), -1)
    count(matches) > 0
    msg := sprintf("Line %d: Avoid curl bashing", [i])
}

# Do not upgrade your system packages
warn[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    regex.match(".*?(apk|yum|dnf|apt|pip).+?(install|dist-upgrade|upgrade|update).*", lower(val))
    msg := sprintf("Line %d: Do not upgrade your system packages: %s", [i, val])
}

# Do not use ADD if possible
deny[msg] {
    some i
    input[i].Cmd == "add"
    msg := sprintf("Line %d: Use COPY instead of ADD", [i])
}

# Any user defined
any_user {
    some i
    input[i].Cmd == "user"
}

# Require USER
deny[msg] {
    not any_user
    msg := "Do not run as root, use USER instead"
}

# Do not use forbidden users
forbidden_users = [
    "root",
    "toor",
    "0"
]

deny[msg] {
    some i
    input[i].Cmd == "user"
    user := lower(input[i].Value[0])
    forbidden_users[_] == user
    msg := sprintf("Line %d: Last USER directive (USER %s) is forbidden", [i, user])
}

# Do not sudo
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg := sprintf("Line %d: Do not use 'sudo' command", [i])
}

# Use multi-stage builds
default multi_stage = false

multi_stage = true {
    some i
    input[i].Cmd == "copy"
    val := concat(" ", input[i].Flags)
    contains(lower(val), "--from=")
}

deny[msg] {
    multi_stage == false
    msg := "You COPY, but do not appear to use multi-stage builds..."
}
