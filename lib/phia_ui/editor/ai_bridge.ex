defmodule PhiaUi.Editor.AiBridge do
  @moduledoc """
  Behaviour for AI-powered editor operations.

  Defines the contract for AI text generation, summarization, rewriting, and
  translation. Implement this behaviour in your application to connect PhiaUI
  editor AI components to your preferred LLM provider (OpenAI, Anthropic, etc.).

  ## Usage

  Define a module that `use`s this behaviour:

      defmodule MyApp.AiProvider do
        use PhiaUi.Editor.AiBridge

        @impl true
        def generate(prompt, context, opts) do
          # Call your LLM API
          {:ok, "Generated text..."}
        end

        @impl true
        def summarize(text, opts) do
          {:ok, "Summary of the text..."}
        end
      end

  All callbacks have default implementations that return `{:error, :not_configured}`,
  so you only need to implement the ones you use.

  ## Configuration

  Store your provider module in application config:

      config :phia_ui, :ai_bridge, MyApp.AiProvider

  Then retrieve it at runtime:

      bridge = Application.get_env(:phia_ui, :ai_bridge, PhiaUi.Editor.AiBridge.Noop)
  """

  @doc """
  Generates text from a prompt string and optional context map.

  The `context` map may include keys like `:editor_content`, `:selection`,
  `:cursor_position`, etc. Options are provider-specific (model, temperature, etc.).

  ## Examples

      AiBridge.generate("Continue this paragraph", %{editor_content: "..."}, model: "gpt-4")
      {:ok, "The generated continuation..."}
  """
  @callback generate(prompt :: String.t(), context :: map(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}

  @doc """
  Summarizes the given text.

  Options may include `:max_length`, `:style` (`:bullet_points`, `:paragraph`), etc.

  ## Examples

      AiBridge.summarize("Long article text...", max_length: 200)
      {:ok, "A concise summary..."}
  """
  @callback summarize(text :: String.t(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}

  @doc """
  Rewrites text in the given style.

  The `style` atom indicates the desired tone/style:
  `:professional`, `:casual`, `:concise`, `:detailed`, `:creative`, etc.

  ## Examples

      AiBridge.rewrite("This is kinda good", :professional, [])
      {:ok, "This demonstrates considerable quality."}
  """
  @callback rewrite(text :: String.t(), style :: atom(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}

  @doc """
  Translates text to the target language.

  The `target_language` is a human-readable language name (e.g., "Spanish", "Japanese").

  ## Examples

      AiBridge.translate("Hello, world!", "Spanish", [])
      {:ok, "Hola, mundo!"}
  """
  @callback translate(text :: String.t(), target_language :: String.t(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour PhiaUi.Editor.AiBridge

      @impl true
      def generate(_prompt, _context, _opts) do
        {:error, :not_configured}
      end

      @impl true
      def summarize(_text, _opts) do
        {:error, :not_configured}
      end

      @impl true
      def rewrite(_text, _style, _opts) do
        {:error, :not_configured}
      end

      @impl true
      def translate(_text, _target_language, _opts) do
        {:error, :not_configured}
      end

      defoverridable generate: 3, summarize: 2, rewrite: 3, translate: 3
    end
  end
end

defmodule PhiaUi.Editor.AiBridge.Noop do
  @moduledoc """
  Default no-op AI bridge implementation.

  Returns `{:error, :not_configured}` for all operations. Used as a fallback
  when no AI provider has been configured.
  """

  use PhiaUi.Editor.AiBridge
end
