defmodule TFLiteElixir.Coral do
  @moduledoc """
  This module contains libcoral C++ API, which provides
  convenient functions to perform inferencing and on-device transfer learning
  with TensorFlow Lite models on [Coral devices](https://coral.ai/products/).
  """

  import TFLiteElixir.Errorize

  alias TFLiteElixir.FlatBufferModel

  @doc """
  Checks whether a tflite model contains any Edge TPU custom operator.
  """
  @spec contains_edge_tpu_custom_op?(%FlatBufferModel{}) :: boolean() | {:error, String.t()}
  def contains_edge_tpu_custom_op?(%FlatBufferModel{model: model}) do
    :tflite_beam_coral.contains_edge_tpu_custom_op?(model)
  end

  @doc """
  Returns a list of connected edge TPU devices.
  """
  @spec edge_tpu_devices() :: [String.t()] | {:error, String.t()}
  def edge_tpu_devices() do
    :tflite_beam_coral.edge_tpu_devices()
  end

  @doc """
  Returns TPU context or an error-tuple if requested TPU context is not available.

  ### Keyword Parameters
  - `device`: `String.t()`. Possible values are

    - ""      -- any TPU device
    - "usb"   -- any TPU device on USB bus
    - "pci"   -- any TPU device on PCIe bus
    - ":N"    -- N-th TPU device, e.g. ":0"
    - "usb:N" -- N-th TPU device on USB bus, e.g. "usb:0"
    - "pci:N" -- N-th TPU device on PCIe bus, e.g. "pci:0"

    Default value is `""`.

    Consider 2 USB devices and 4 PCIe devices connected to the host. The way to
    reference specifically USB devices:

      "usb:0", "usb:1".

    The way to reference specifically PCIe devices:

      "pci:0", "pci:1", "pci:2", "pci:3".

    The generic way to reference all devices (no assumption about device type):

      ":0", ":1", ":2", ":3", ":4", ":5".

  - `options`: `Map`. Possible key-value pairs are

    - "Performance": `String.t()`

      - "Low"
      - "Medium"
      - "High"
      - "Max"

      Default is "Max".

      Adjust internal clock rate to achieve different performance / power balance.

    - "Usb.AlwaysDfu": `boolean`

      - `true`
      - `false`

      Default is `false`.

      Always perform device firmware update after reset. DFU is usually only
      necessary after power cycle.

    - "Usb.MaxBulkInQueueLength": `String.t()`

      - ["0",.., "255"] (Default is "32")

      Larger queue length may improve USB performance on the direction from
      device to host.

      All TPUs are always enumerated in the same order assuming hardware
      configuration doesn't change (no added/removed devices between enumerations).
      Under the assumption above, the same index N will always point to the same
      device.
  """
  @spec get_edge_tpu_context(Keyword.t()) :: {:ok, reference()} | {:error, String.t()}
  def get_edge_tpu_context(opts \\ []) do
    :tflite_beam_coral.get_edge_tpu_context(opts)
  end

  deferror(get_edge_tpu_context(opts))

  @doc """
  Creates a new interpreter instance for an Edge TPU model.

  Also consider using `make_edge_tpu_interpreter!()`.

  ##### Positional Parameters

  - `model`: `FlatBufferModel`. The tflite model.
  - `edgetpu_context`: `reference()`.

    The Edge TPU context, from `TFLiteElixir.Coral::get_edge_tpu_context`.

    If left `nil`, the given interpreter will not resolve an Edge TPU delegate.
    PoseNet custom op is always supported.

  ##### Keyword Parameters (todo)

  - `resolver`: May be `nil` to use a default resolver.
  - `error_reporter`: May be `nil` to use default error reporter,
    but beware that if null, tflite runtime error messages will not return.
  - `interpreter`: The pointer to receive the new interpreter.
  """
  @spec make_edge_tpu_interpreter(%FlatBufferModel{}, reference()) ::
          {:ok, reference()} | {:error, String.t()}
  def make_edge_tpu_interpreter(%FlatBufferModel{model: model}, edgetpu_context) do
    :tflite_beam_coral.make_edge_tpu_interpreter(model, edgetpu_context)
  end

  deferror(make_edge_tpu_interpreter(model, edgetpu_context))

  @doc """
  Returns a dequantized version of the given tensor.
  """
  @spec dequantize_tensor(reference(), non_neg_integer(), term()) :: [number()] | {:error, String.t()}
  def dequantize_tensor(interpreter, tensor_index, as_type \\ nil) do
    :tflite_beam_coral.dequantize_tensor(interpreter, tensor_index, as_type)
  end
end
