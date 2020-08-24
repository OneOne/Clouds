using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

//[PostProcess(typeof(NoiseEffectRenderer), PostProcessEvent.AfterStack, "Custom/NoiseEffect")]
[Serializable, VolumeComponentMenu("Post-processing/Custom/NoiseEffect")]
public sealed class NoiseEffect : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Noise number X")]
    public ClampedFloatParameter X = new ClampedFloatParameter(0.5f, 0.0f, 1.0f);
    public ClampedFloatParameter Y = new ClampedFloatParameter(0.5f, 0.0f, 1.0f);

    Material m_Material;

    public bool IsActive() => m_Material != null
        && X.value > 0.0f
        && Y.value > 0.0f
        ;

    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    public override void Setup()
    {
        if(Shader.Find("Hidden/Shader/NoiseEffect") != null)
        {
            m_Material = new Material(Shader.Find("Hidden/Shader/NoiseEffect"));
        }
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null) return;
        m_Material.SetFloat("_X", X.value);
        m_Material.SetFloat("_Y", Y.value);
        m_Material.SetTexture("_InputTexture", source);
        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }

    public override void Cleanup() => CoreUtils.Destroy(m_Material);
}

//public sealed class NoiseEffectRenderer : PostProcessEffectRenderer<NoiseEffect>
//{
//    public override void Render(PostProcessRenderContext context)
//    {
//        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/NoiseEffect"));
//        sheet.properties.SetFloat("_X", settings.X);
//        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
//    }
//}
