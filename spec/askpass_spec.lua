local helpers = require("spec.test_helpers")

local function env_variable(var)
	if vim.o.shell:match("cmd.exe$") then
		return "echo %" .. var .. "%"
	elseif vim.o.shell:match("pwsh$") or vim.o.shell:match("powershell$") then
		return "echo $Env:" .. var
	else
		return "echo $" .. var
	end
end

local function invalid_env_value(var)
	if vim.o.shell:match("cmd.exe$") then
		return "%" .. var .. "%"
	else
		return ""
	end
end

local assert = require("luassert")

describe("`askpass` option", function()
	before_each(function()
		helpers.setup_tests({ askpass = true })
	end)

	it("should set SSH_ASKPASS environment variable", function()
		local cmd = env_variable("SSH_ASKPASS")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are_not.same({ cmd, "" }, output)
		assert.are_not.same({ cmd, invalid_env_value("SSH_ASKPASS") }, output)
	end)

	it("should set SUDO_ASKPASS environment variable", function()
		local cmd = env_variable("SUDO_ASKPASS")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are_not.same({ cmd, "" }, output)
		assert.are_not.same({ cmd, invalid_env_value("SUDO_ASKPASS") }, output)
	end)

	it("should set GIT_ASKPASS environment variable", function()
		local cmd = env_variable("GIT_ASKPASS")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are_not.same({ cmd, "" }, output)
		assert.are_not.same({ cmd, invalid_env_value("GIT_ASKPASS") }, output)
	end)

	it("should set SSH_ASKPASS_REQUIRE to force", function()
		local cmd = env_variable("SSH_ASKPASS_REQUIRE")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are.same({ cmd, "force" }, output)
	end)

	it("should point all ASKPASS variables to the same script", function()
		local cmd
		if vim.o.shell:match("cmd.exe$") then
			cmd = "echo %SSH_ASKPASS% %SUDO_ASKPASS% %GIT_ASKPASS%"
		elseif vim.o.shell:match("pwsh$") or vim.o.shell:match("powershell$") then
			cmd = "echo $Env:SSH_ASKPASS $Env:SUDO_ASKPASS $Env:GIT_ASKPASS"
		else
			cmd = "echo $SSH_ASKPASS $SUDO_ASKPASS $GIT_ASKPASS"
		end

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		local paths = vim.split(output[2], " ")
		assert.are.equal(3, #paths)
		assert.are.equal(paths[1], paths[2])
		assert.are.equal(paths[2], paths[3])
	end)

	it("should preserve user environment variables", function()
		helpers.setup_tests({ askpass = true, environment = { MY_VAR = "hello" } })
		local cmd = env_variable("MY_VAR")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are.same({ cmd, "hello" }, output)
	end)

	it("should inject -A flag into sudo commands", function()
		helpers.compile({ args = "echo sudo make" })

		local output = helpers.get_output()
		assert.are.same({ "echo sudo make", "sudo -A make" }, output)
	end)

	it("should not double -A if already present", function()
		helpers.compile({ args = "echo sudo -A make" })

		local output = helpers.get_output()
		assert.are.same({ "echo sudo -A make", "sudo -A make" }, output)
	end)

	it("should not modify words starting with sudo", function()
		helpers.compile({ args = "echo sudoers" })

		local output = helpers.get_output()
		assert.are.same({ "echo sudoers", "sudoers" }, output)
	end)

	it("should clean up the askpass script after compilation", function()
		local cmd = env_variable("SSH_ASKPASS")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		local script_path = output[2]
		assert.are.equal(0, vim.fn.filereadable(script_path))
	end)
end)

describe("without `askpass` option", function()
	before_each(function()
		helpers.setup_tests({})
	end)

	it("should not set SSH_ASKPASS", function()
		local cmd = env_variable("SSH_ASKPASS")

		helpers.compile({ args = cmd })

		local output = helpers.get_output()
		assert.are.same({ cmd, invalid_env_value("SSH_ASKPASS") }, output)
	end)
end)
