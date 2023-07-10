import argparse
import math
import os
import pathlib
import sys
from logging import getLogger, basicConfig, INFO, DEBUG, ERROR
import warnings
import matplotlib
import matplotlib.pyplot as plot
from scipy.io import wavfile
import numpy
from datetime import datetime

from scipy.io.wavfile import WavFileWarning

logger = getLogger("compute-audio-space")
basicConfig(level=ERROR, format="%(levelname)s: %(message)s")

THRESHOLD = 1.E-15


class Color:
    N_SHADES = 10

    def __init__(self, n_shades):
        self.n_shades = max(n_shades, self.N_SHADES)
        self._index = -1
        c = numpy.arange(1, self.n_shades + 1)
        norm = matplotlib.colors.Normalize(vmin=c.min(), vmax=c.max())
        self.cmap = matplotlib.cm.ScalarMappable(norm=norm, cmap=matplotlib.cm.Set1)
        self.cmap.set_array([])

    def next(self):
        self._index += 1
        return self.cmap.to_rgba(self._index % self.n_shades)


def fft_audio(opt):
    """
    in: opt: command line option object.
            Attributes:
                 - audio: list of audio files
                 - output: output file path for fft plot
    """
    if opt.debug:
        logger.setLevel(DEBUG)
    fig, subplots = _start_plot(height=opt.figureHeight, width=opt.figureWidth)
    color = Color(len(opt.audio))
    # Plot in reverse order, so that the first fft is on top
    for i, file in enumerate(reversed(opt.audio)):
        logger.info(f"audio file: {file}")
        duration, rate, audio_data = _read_audio(file)
        _plot_audio(rate=rate, audio_data=audio_data,
                    label=f"{_file_name(file)} ({duration})",
                    subplots=subplots, color=color.next())
    _end_plot(opt, fig, subplots)


def _file_name(file):
    chunks = str(file).split(sep=os.sep)
    return f"{chunks[-2]}/{chunks[-1]}" if len(chunks) > 1 and str(chunks[-2]).startswith('.') else str(chunks[-1])


def _start_plot(height: int, width: int):
    fig, subplots = plot.subplots(2, 1, figsize=(width, height))
    return fig, subplots


def _end_plot(opt, fig, subplots):
    fig.legend(*subplots[0].get_legend_handles_labels(), loc='upper center', ncol=min(len(opt.audio), 2),
               bbox_transform=plot.gcf().transFigure)
    for s in subplots:
        s.set_xlabel('Frequency (kHz)')
    logger.debug(f"show option: {opt.show}")
    if opt.show[0] == 'yes':
        plot.show()
    logger.debug(f"output: {opt.output}")
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=UserWarning)
        plot.savefig(opt.output)


def _scale_re(arr: numpy.ndarray) -> numpy.ndarray:
    """
    in: complex numpy array
    """
    # Scaling formulae: Re(arr) + delta
    #   A delta is added to remove null values
    return numpy.sign(numpy.real(arr)) * numpy.log10(numpy.abs(numpy.real(arr)) + THRESHOLD)


def _scale_im(arr: numpy.ndarray) -> numpy.ndarray:
    """
    in: complex numpy array
    """
    # Scaling formulae: Im(arr) + delta
    #   A delta is added to remove null values
    return numpy.sign(numpy.imag(arr)) * numpy.log10(numpy.abs(numpy.imag(arr)) + THRESHOLD)


def _to_duration(ss) -> str:
    if ss < 60:
        return datetime.strptime(f"{round(ss, 6)}", "%S.%f").strftime(
            "%M:%S.%f")[:-4]
    elif 60 <= ss < 60 * 60:
        return datetime.strptime(f"{round(ss / 60)}:{round(ss % 60, 6)}", "%M:%S.%f").strftime(
            "%M:%S.%f")[:-4]
    else:
        Exception("Duration(s) Above A Hour Not Implemented")


def _read_audio(file_name) -> (str, float, numpy.ndarray):
    try:
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore", category=WavFileWarning)
            rate, audio_data = wavfile.read(file_name)
            return _to_duration(audio_data.size / rate / len(audio_data.shape)), rate, audio_data
    except FileNotFoundError as error:
        logger.error(error)
        exit(2)
    except Exception:
        raise


def _compute_fft(audio_data) -> numpy.ndarray:
    if len(audio_data.shape) == 2:
        fft_data = numpy.fft.fft(audio_data.sum(axis=1) / 2)
    else:
        fft_data = numpy.fft.fft(audio_data)
    return fft_data


def _plot_audio(rate, audio_data, label, subplots, color) -> None:
    n = len(audio_data)
    fft_data = _compute_fft(audio_data)
    freq = numpy.arange(0, n, 1.0) * (rate / n) / 1000
    logger.info(f"#_freq={n}, min_freq={freq[0]}(khz), max_freq={freq[-1]}(khz)")
    subplots[0].plot(freq, _scale_re(fft_data), color=color, label=label)
    subplots[0].set_ylabel("Re (log)")
    subplots[1].plot(freq, _scale_im(fft_data), color=color, label=label)
    subplots[1].set_ylabel("Im (log)")
    return


def int_audio(opt):
    """
    in: opt: command line option object.
            Attributes:
                 - audio: list of audio files
                 - output: output file path for fft plot
    """
    assert opt.factor[0] > 1
    if opt.debug:
        logger.setLevel(DEBUG)
    logger.info(f"audio file: {opt.audio}")
    duration, rate, audio_data = _read_audio(opt.audio)
    new_audio_data = _interpolate(audio_data, opt.factor[0])
    wavfile.write(opt.output, rate, numpy.real(new_audio_data).astype(numpy.int16))


def _interpolate(audio_data, padding) -> numpy.ndarray:
    if len(audio_data.shape) == 2:
        fft_data = numpy.array(numpy.fft.fft(audio_data[:, 0]), numpy.fft.fft(audio_data[:, 1]))
        padded_fft = numpy.array(numpy.insert(fft_data[:, 0], numpy.repeat(range(1, len(audio_data)), (padding - 1)), 0, axis=0),
                                 numpy.insert(fft_data[:, 1], numpy.repeat(range(1, len(audio_data)), (padding - 1)), 0, axis=0))
        return numpy.array(numpy.fft.ifft(padded_fft[:, 0]), numpy.fft.ifft(padded_fft[:, 1]))
    else:
        fft_data = numpy.fft.fft(audio_data)
        padded_fft = numpy.insert(fft_data, numpy.repeat(range(1, len(audio_data)), (padding - 1)), 0, axis=0)
        return numpy.fft.ifft(padded_fft)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="scripts")
    subparsers = parser.add_subparsers(help="select the action's command")
    sub = subparsers.add_parser("fft", help="compute fourier's transform")
    sub.add_argument("--audio", "-a", help=f"audio file(s)", nargs="+", type=pathlib.Path)
    sub.add_argument("--figureHeight", "-fh", help=f"figure's height in centimeters", nargs=1, type=int, default=10)
    sub.add_argument("--figureWidth", "-fw", help=f"figure's width in centimeters", nargs=1, type=int, default=20)
    sub.add_argument("--show", "-s", help=f"show or hide plot", nargs=1, choices=['yes', 'no'], default='no')
    sub.add_argument("--debug", "-d", help=f"debug mode", action='store_true')
    sub.add_argument("--output", "-o", help=f"output fft", nargs="?", type=pathlib.Path)
    sub.set_defaults(func=fft_audio)
    sub_1 = subparsers.add_parser("int", help="interpolate audio file(s)")
    sub_1.add_argument("--audio", "-a", help=f"audio file(s)", nargs="?", type=pathlib.Path)
    sub_1.add_argument("--factor", "-f", help=f"factor number x audio duration", nargs=1, type=int, default=[2])
    sub_1.add_argument("--output", "-o", help=f"output interpolate", nargs="?", type=pathlib.Path)
    sub_1.add_argument("--debug", "-d", help=f"debug mode", action='store_true')
    sub_1.set_defaults(func=int_audio)
    args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])
    try:
        args.func(args)
    except Exception as e:
        raise e