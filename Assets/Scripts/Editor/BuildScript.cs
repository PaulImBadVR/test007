using UnityEditor;

public class BuildScript
{
    public static void PerformBuild()
    {
        string[] scenes = { "Assets/SampleScene.unity" };
        string outputPath = "Builds/WindowsBuild.exe";
        BuildPipeline.BuildPlayer(scenes, outputPath, BuildTarget.StandaloneWindows64, BuildOptions.None);
    }
}
