## DataPull

This bundle provides intelligent data replication between two HPCC Systems
clusters.  Only changes between the two clusters are replicated, including both
regular files and superfile structures.

## Requirements

The code included in this bundle is written entirely in ECL.  No extra plugins
or third party tools are required, though functions from the Std library
(included with the platform) are used.  HPCC 6.0.0 or later is required.

## License and Version
This software is licensed under the Apache v2 license.  A link to the license,
as well as the current version of this software, can be found in the
[Bundle.ecl](Bundle.ecl)
file.

## Installation

To install a bundle to your development machine, use the ecl command line tool:

	ecl bundle install https://github.com/dcamper/DataPull.git

For complete details, see the Client Tools Manual, available in the download
section of https://hpccsystems.com.

Note that is possible to use this code without installing it as a bundle.  To do
so, simply make it available within your IDE and just ignore the Bundle.ecl
file. With the Windows IDE, the DataPull directory must not be a top-level item
in your repository list; it needs to be installed one level below the top level,
such as within your "My Files" folder.  If you use this technique then your ECL
IMPORT statement will change slightly as well:  instead of
`IMPORT DataPull;` you will have to use `IMPORT DataPull.DataPull;`.

<a name="release_notes"></a>
### Release Notes
<details>
<summary>Click to expand</summary>

|Version|Notes|
|:----:|:-----|
|1.0.0|Initial public release|
|1.0.1|Change SEQUENTIAL calls to ORDERED for performance (avoids subgraph duplication)|
|1.1.0|Add disableContentCheck option|
|1.2.0|Add enableNoSplit option|
|1.2.1|Avoid copying subfiles that already exist on the destination but are not yet attached to their superfiles|
</details>

## Overview

This is strictly a "pull" copy scheme where the intention is to make the
local system (whatever is running this code) "mirror" the remote system,
strictly for those files that match one or more of the given filename
patterns.  Care should be taken when specifying filename patterns, especially
those with prefix and suffix wildcards (e.g. \*fubar\*).  Any local file or
superfile that matches a pattern is subject to modification or deletion,
depending on whether that file exists on the remote system or not.  It is
easy to lose local files that way, by inadvertently referencing them with
a filename pattern intended for something else.

The full contents of superfiles will be copied as well, even if the subfiles
do not match any of the filename patterns.  Relatedly, superfile contents
are modified if necessary, such as when the remote system lists different
subfiles for a superfile that the local system already has.  In that case,
the code will copy any subfiles (if necessary) and alter the superfile
relationships so they match the remote system.

Regular files are copied only if necessary.  If a file already exists in both
the systems, it is examined for change (size, content or metadata) and
copied only if a difference is found.  Checking the content takes extra work
and, if the number of files to be examined is large, may be time-consuming.
If you are confident that files are not overwritten in the remote system
(meaning, a file with a given name will never change its contents) then you
can disable the content check with a `disableContentCheck` parameter.

Optional cluster name mapping is supported.  This covers the case where a
remote file may exist on a cluster with a name that doesn't exist on the
local system.  The most common example is probably 'thor' vs. 'mythor' --
two common Thor cluster names that seem to pop up in simple configurations.
The map indicates on which local cluster to put a new or modified file,
file, given the name of the remote cluster.

The code can be executed in "dry run" mode (which is the default).  In this
mode, every action that would normally be taken is compiled into a list of
commands and then displayed in a workunit result.  This gives you the
opportunity to see what the code would do if only given the chance.

**This code must be executed on the hthor HPCC engine.**  If you try to execute
it on a different engine then it will fail with an informative error.

Further information can be found within the [DataPull.ecl](DataPull.ecl) file.

## Known Limitation

This code will not correctly process Roxie indexes that are in use on the local
system and need to be modified, nor will it update local Roxie queries that need
new data coming in from the remote system.

## Example code

```
IMPORT DataPull;

// Mirror all of my files and any file or superfile with 'search' in the name
FILE_PATTERNS := ['dcamper::*', '*search*'];
REMOTE_DALI := '10.173.147.1';

// Make sure that any remote files existing on the 'hthor__myeclagent'
// cluster are copied to the local 'hthor' cluster
clusters := DATASET
	(
		[
			{'hthor__myeclagent', 'hthor'}
		],
		DataPull.ClusterMapRec
	);

DataPull.Go
	(
		REMOTE_DALI,
		FILE_PATTERNS,
		clusterMap := clusters,
		disableContentCheck := FALSE,
		enableNoSplit := FALSE,
		isDryRun := TRUE
	);
```
