IMPORT Std;
EXPORT Bundle := MODULE(Std.BundleBase)
    EXPORT Name := 'DataPull';
    EXPORT Description := 'HPCC inter-cluster data replication';
    EXPORT Authors := ['Dan S. Camper'];
    EXPORT License := 'http://www.apache.org/licenses/LICENSE-2.0';
    EXPORT Copyright := 'Copyright (C) 2021 HPCC Systems';
    EXPORT DependsOn := [];
    EXPORT PlatformVersion := '6.0.0';
    EXPORT Version := '1.1.0';
END;
