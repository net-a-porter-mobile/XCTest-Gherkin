class TravisFormatter < XCPretty::Simple

  FEATURE_MATCHER = /^\s*Feature: (.+)$/
  SCENARIO_MATCHER = /^\s*Scenario: (.+)$/
  STEP_MATCHER = /^\s*step (.+)\s{2}\(((?:.+):(?:\d+))\)$/
  TEST_CASE_FAILED_MATCHER = /^\s*Test Case\s'-\[(.*)\s(.*)\]'\sfailed\s\((\d*\.\d{3})\sseconds\)/
  
  def initialize (use_unicode, colorize)
    super
    @performed_step = nil
  end

  def format_other(message);
    case message.strip
    when TEST_CASE_FAILED_MATCHER
      return format_failed_test($1, $2, $3)
    when FEATURE_MATCHER
      return format_feature_or_scenario(message)
    when SCENARIO_MATCHER
      return format_feature_or_scenario(message)
    else
      return format_performed_step(method(:green))
    end
  end

  # renderes cached step and clears cache
  def format_performed_step(color)
    unless @performed_step.nil?
      text = color.call(@performed_step)
      @performed_step = nil
      return text
    else
      return EMPTY
    end
  end

  # xcpretty detects everything starting with 4 spaces as shell command
  # renders cached step and caches new step
  def format_shell_command(command, arguments);
    case "#{command} #{arguments}"
    when STEP_MATCHER
      text = format_performed_step(method(:green))
      @performed_step = "    #{$1}  " + gray("(#{$2})")
      return text
    else
      return super
    end
  end

  def format_text_after_step(color, separator, text)
    unless @performed_step.nil?
      return format_performed_step(color) + separator + text
    else
      return text
    end
  end
  
  def format_feature_or_scenario(message)
    text = ("\n\u{001B}[0;39m" + message).strip + "\u{001B}[0;0m"
    format_text_after_step(method(:green), "\n", text)
  end

  def format_passing_test(suite, test, time)
    text = super
    format_text_after_step(method(:green), "\n\n", text)
  end

  # same as format_passing_test but for failed test
  def format_failed_test(suite, test_case, time)
    text = INDENT + format_test("#{test_case} (#{colored_time(time)} seconds)", :fail)
    format_text_after_step(method(:green), "\n\n", text)
  end

  # formats test failure with snippet
  def format_failing_test(suite, test, reason, file_path);
    text = format_failure({file_path: file_path, reason: reason})
    format_text_after_step(method(:red), "\n", text)
  end

  def format_test_run_started(name)
    EMPTY
  end
  
  def format_test_suite_started(name)
    yellow(heading("Test Suite", name, yellow("started")))
  end

  def format_test_summary(executed_message, failures_per_suite)
    EMPTY
  end

  def format_failure(f)
    snippet = Snippet.from_filepath(f[:file_path])
    output = INDENT + "#{red(f[:reason])}\n"
    output += INDENT + "#{cyan(f[:file_path])}\n"
    return output if snippet.contents.empty?

    output += INDENT + "```\n"
    if @colorize
      output += Syntax.highlight(snippet)
    else
      output += snippet.contents
    end
    output += INDENT + "```"

    output
  end

  def gray(text)
    ansi_parse(text, :white)
  end

  def green(text)
    ansi_parse(text, :green)
  end

end

TravisFormatter
