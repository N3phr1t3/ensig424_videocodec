# ENSC 424 Group 11 MATLAB framework

AI-written scaffold and documentation. See `AI_usage.txt`.

This package contains experiment support and deliberately unfinished codec
stubs. It cannot compress a video yet. No codec algorithms, encoder pipeline,
decoder pipeline, or invented codec results are included.

## Proposal responsibilities

| Member | Components to implement |
| --- | --- |
| Ankit Saini | Integer transform and inverse transform |
| Arshiya Mohammadi Angha | Quantization, entropy coding, and inverse operations |
| Jade Roberts | Intra-frame prediction and filtering |
| Armaan Singh | Motion estimation and compensation |
| All members | Encoder/decoder integration, testing, report, presentation |

These owners follow the proposal. Inverse operations are included as the
corresponding decoder work. The function signatures are suggested interfaces
for the team to agree on; the proposal did not specify exact MATLAB interfaces.

## Files

- `config.m`: input, function handles, component parameters, sweep and plot settings.
- `run_project.m`: load the config and run the experiment.
- `components/`: encoder, decoder, and ten algorithm stubs with named owners.
- `support/`: Y reading, experiment runner, byte counting, metrics, and plots.
- `check_support.m`: small tests for support code; no codec implementation.
- `data/`: place your source Y file here. Videos are not bundled.
- `results/`: created when you run an experiment.

## How to run

1. Extract the ZIP and open the `ENSC424_Framework` folder in MATLAB.
2. Put `foreman_qcif.y` in `data/`, or edit `cfg.input.file`.
3. Set the actual width, height, frame count, and first frame in `config.m`.
4. Implement the team codec stubs, then run:

```matlab
run_project
```

Before implementing the codec, you can run `check_support`. The normal runner
will intentionally stop with `Codec:NotImplemented` once it reaches a stub
(or report missing video data first). It will not invent a bitrate or PSNR.

The support code uses base MATLAB functions and does not require an image or
video toolbox. Your later components may have their own dependencies.

Validation note: MATLAB R2026b's static code analyzer found no diagnostics in
the support/config/run/test files; the empty component stubs have expected
unused-input/unset-output warnings. MATLAB startup failed with MathWorks
service error 5202, so runtime checks could not be completed here.
Run `check_support` locally before integrating.

## Config and function selection

The encoder and decoder pair is selected by one line:

```matlab
cfg.codec = struct('encode', @encode_video, 'decode', @decode_video);
```

To switch both implementations, replace that line, for example:

```matlab
cfg.codec = struct('encode', @my_encoder, 'decode', @my_decoder);
```

Your replacement functions must be on the MATLAB path and use the same
signatures. `my_encoder` and `my_decoder` are examples, not included functions.
To select one component, change its handle, such as
`cfg.components.motionEstimate = @my_motion_estimate;`.
`@name` means a handle to the function called `name`.

The runner calls only the selected encoder and decoder. The team encoder must
call the selected component handles. Choosing a handle does not implement or
automatically connect that stage. When switching a transform, entropy coder,
or quantizer, also choose its matching inverse.

`cfg.params` contains quality, quantizer scale, transform/intra/motion block
sizes, search range, motion precision, keyframe interval, and filtering enable.
Add more fields as needed. These are passed to your encoder unchanged; your
codec must decide how they affect coding. In particular, scale is a codec
parameter, not image resizing, and the team must define its quantization meaning.
The support code accepts quality 1-100 and positive scale values.

Changing input dimensions describes a different raw file layout; it does not
resize the source. Input is headerless, row-major, 8-bit luminance only (no UV
planes). The runner supports any positive dimensions. Padding for block
alignment and cropping after decoding belong to your codec.

## Single runs and sweeps

For a single run, use `cfg.experiment.mode = 'single';` and set
`cfg.params.quality` and `cfg.params.scale` to the desired values.

For the professor's five quality factors, edit these lines in `config.m`:

```matlab
cfg.experiment.mode = 'sweep';
cfg.experiment.parameter = 'quality';
cfg.experiment.values = [10 30 50 70 90];
```

For a scale sweep:

```matlab
cfg.experiment.mode = 'sweep';
cfg.experiment.parameter = 'scale';
cfg.experiment.values = [0.5 1 2 4];
```

Run `run_project` after editing. Each sweep changes only the named parameter;
all other settings remain fixed. The same random seed is used for each point.
Sweep arrays preserve your order, and duplicate values are separate runs.

To adjust settings temporarily without editing the config file:

```matlab
addpath(pwd, fullfile(pwd,'support'), fullfile(pwd,'components'));
cfg = config();
cfg.experiment.mode = 'sweep';
cfg.params.motionBlockSize = [8 8];
[results, folder] = run_experiments(cfg);
```

## Encoder and decoder contract

```matlab
encode_video(frames, encodedFolder, cfg)
frames = decode_video(encodedFolder)
```

The encoder receives an H x W x N `uint8` array of original Y frames and a new,
empty folder. It must close its files before returning. Write every file the
decoder needs into this folder: compressed samples, residuals, vectors,
headers, dimensions, frame count, tables, modes, and needed quality/scale data.
Use real packed bytes on disk, not theoretical entropy or `whos` memory sizes.

The decoder receives only the encoded folder. It must reconstruct the video
using those files and the agreed codec implementation, without the original
video, encoder state, globals, or the experiment config saved outside it.
Record needed settings and implementation/mode identifiers in the package;
the team decoder must dispatch to the corresponding inverse functions.
Fixed constants may be defined by your codec specification.

Return H x W x N numeric samples in [0,255] at the original dimensions.
Decide rounding and clipping in your codec; the metric code does not apply
either silently. Do not write decoder output or temporary files into the
encoded folder. The runner checks that filenames and sizes remain unchanged;
this is not a content-hash check or a standalone-decoding guarantee.

## Measurements and output

Each call makes a new experiment folder and prints its location. It contains:

- `results.csv`: one row per successful point, including bytes, bpp, MSE, both
  PSNR summaries, encode/decode seconds, FPS, quality, scale, and input details.
- `config.mat`: the experiment settings, including handles and block sizes.
- `run_001/`, etc.: each point's config, counted `encoded/` package,
  `encoded_files.csv` byte inventory, and `per_frame.csv`.
- `rate_quality.fig/.png` and `timing.fig/.png`: plots after all points succeed.

Failures stop the run and write `error.txt` in the failed point's folder.
Earlier successful CSV rows remain. A failed point never gets a success row.

Rate is `8 * sum(actual encoded file bytes) / (width * height * frame count)`.
Every file in `encoded/`, including nested files and MAT overhead, is counted.
Config snapshots, CSVs, plots, and the source are outside that folder and are
not decoder inputs. Do not place required decoder metadata outside it.
Block padding does not enlarge the bpp denominator.

MSE uses all original Y samples. The main `PSNR_dB` is
`10*log10(255^2 / pooled_MSE)`. `MeanFramePSNR_dB` averages the individual
frame PSNR values; these are generally different. Exact reconstruction gives
`Inf`, which is preserved in CSVs and cannot be shown as a finite plot point.
Confirm the professor's PSNR averaging convention before a formal comparison.

Each timer measures one encoder or decoder call, including its file I/O.
Source reading, metric calculation, byte inventory, and reporting are excluded.
There is no warm-up or automatic timing average. Compare timings on the same
machine and repeat runs if startup/cache effects matter. Full selected input
and decoded arrays are held in memory; reduce frame count for very large videos.

## Editable legends and comparing implementations

Set `cfg.plot.label` for the run's legend. Saved `.fig` plots remain editable.
To compare two completed sweeps and choose new labels without rerunning them:

```matlab
addpath('support');
plot_results({'path/to/baseline/results.csv', 'path/to/new/results.csv'}, ...
             {'Baseline', 'New motion estimator'}, true);
```

Use matching source content and frame ranges. The function checks sequence
name, dimensions, and frame range; it cannot verify matching source content.
It saves figures beside the first CSV, replacing earlier plot files there.
The original CSVs remain unchanged. You can also open a `.fig` and edit its
legend using MATLAB's plot tools, then save it under a new name.

The supplied professor curve is reported reference data, not measured output
of this framework. It is shown only for `foreman_qcif.y`, 176 x 144, frames
1-100. Set `cfg.plot.showProfessorBenchmark = false` to hide it. The provided
rates are [0.38 0.61 0.80 1.07 1.93] bpp and PSNRs are
[29.12 31.27 32.64 34.10 38.78] dB at qualities [10 30 50 70 90].

## Team next steps

1. Agree on block layouts, component interfaces, quality/scale interpretation,
   bitstream headers, mode identifiers, boundary handling, and filtering placement.
2. Each member implements their components and matching inverse behaviour.
3. Integrate an encoder and decoder. A first baseline can follow the announcement:
   first frame I-coded; later frames predicted from the previous reconstructed
   frame; motion vectors transmitted; residual and I-frame use the same quality.
   This is a suggested integration target, not logic already implemented here.
4. Verify decoding in a fresh MATLAB session with only the encoded package and
   decoder code. Test one frame, multiple frames, another resolution, and sizes
   not divisible by your blocks. Ensure no original frames are used as references
   at the decoder or leaked to it through saved state.
5. Run the five-point baseline sweep; change one component and repeat with the
   same inputs. Compare rate versus PSNR and timing, then test more Y sequences.
6. Add a validated BD-rate comparison later. The project PDF grades final
   performance using BD-rate versus PSNR; this scaffold does not calculate it.
   Keep the real RD points for that comparison and document design iterations.
7. Update AI and member-contribution records as code changes. The report also
   needs reflections on the proposal plan and submission of the source code.

Sources read before building: the attached ENSC 424 course project PDF,
Group 11 proposal (Plan section), and the professor's announcement in this chat.
